################################################################################
# Generate a unique random string for resource name assignment and key pair
################################################################################
resource "random_string" "suffix" {
  length  = 8
  upper   = false
  special = false
}


################################################################################
# Map default tags with values to be assigned to all tagged resources
################################################################################
locals {
  global_tags = {
    Owner                                                                                = var.owner_tag
    ManagedBy                                                                            = "terraform"
    Vendor                                                                               = "Zscaler"
    "zs-app-connector-cluster/${var.name_prefix}-cluster-${random_string.suffix.result}" = "shared"
  }

  # Onboarding method switch. Default is OAuth2; set onboarding_method to
  # "provisioning_key" (or byo_provisioning_key = true) to use the legacy
  # provisioning key flow instead.
  use_provisioning_key = var.onboarding_method == "provisioning_key" || var.byo_provisioning_key
}


################################################################################
# The following lines generates a new SSH key pair and stores the PEM file
# locally. The public key output is used as the instance_key passed variable
# to the ec2 modules for admin_ssh_key public_key authentication.
# This is not recommended for production deployments. Please consider modifying
# to pass your own custom public key file located in a secure location.
################################################################################
resource "tls_private_key" "key" {
  algorithm = var.tls_key_algorithm
}

resource "aws_key_pair" "deployer" {
  key_name   = "${var.name_prefix}-key-${random_string.suffix.result}"
  public_key = tls_private_key.key.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.key.private_key_pem
  filename        = "./${var.name_prefix}-key-${random_string.suffix.result}.pem"
  file_permission = "0600"
}


################################################################################
# 1. Create/reference all network infrastructure resource dependencies for all
#    child modules (vpc, igw, nat gateway, subnets, route tables)
################################################################################
module "network" {
  source                      = "../../modules/terraform-zsac-network-aws"
  name_prefix                 = var.name_prefix
  resource_tag                = random_string.suffix.result
  global_tags                 = local.global_tags
  az_count                    = var.az_count
  vpc_cidr                    = var.vpc_cidr
  public_subnets              = var.public_subnets
  ac_subnets                  = var.ac_subnets
  associate_public_ip_address = var.associate_public_ip_address
}


################################################################################
# 2. Create Bastion Host for workload and AC SSH jump access
################################################################################
module "bastion" {
  source                    = "../../modules/terraform-zsac-bastion-aws"
  name_prefix               = var.name_prefix
  resource_tag              = random_string.suffix.result
  global_tags               = local.global_tags
  vpc_id                    = module.network.vpc_id
  public_subnet             = module.network.public_subnet_ids[0]
  instance_key              = aws_key_pair.deployer.key_name
  bastion_nsg_source_prefix = var.bastion_nsg_source_prefix
}


################################################################################
# 3. Generate App Connector Group name with template variable support
################################################################################
locals {
  # Default naming pattern if not specified
  default_ac_group_name = "${var.aws_region}-${module.network.vpc_id}"

  # User-provided name with variable substitution
  custom_ac_group_name = var.app_connector_group_name != "" ? replace(
    replace(
      replace(
        replace(var.app_connector_group_name, "{region}", var.aws_region),
        "{vpc_id}", module.network.vpc_id
      ),
      "{name_prefix}", var.name_prefix
    ),
    "{random_suffix}", random_string.suffix.result
  ) : local.default_ac_group_name
}


################################################################################
# 4. (Provisioning key flow only) Create the ZPA App Connector Group and
#    Provisioning Key up front so the key can be baked into the launch template
#    user_data. New ASG instances self-enroll using the provisioning key, which
#    is the recommended approach for autoscaling deployments.
################################################################################
module "zpa_app_connector_group_pk" {
  count                                        = local.use_provisioning_key && var.byo_provisioning_key == false ? 1 : 0
  source                                       = "../../modules/terraform-zpa-app-connector-group"
  app_connector_group_name                     = local.custom_ac_group_name
  app_connector_group_description              = "${var.app_connector_group_description}-${var.aws_region}-${module.network.vpc_id}"
  app_connector_group_enabled                  = var.app_connector_group_enabled
  app_connector_group_country_code             = var.app_connector_group_country_code
  app_connector_group_city_country             = var.app_connector_group_city_country
  app_connector_group_latitude                 = var.app_connector_group_latitude
  app_connector_group_longitude                = var.app_connector_group_longitude
  app_connector_group_location                 = var.app_connector_group_location
  app_connector_group_upgrade_day              = var.app_connector_group_upgrade_day
  app_connector_group_upgrade_time_in_secs     = var.app_connector_group_upgrade_time_in_secs
  app_connector_group_override_version_profile = var.app_connector_group_override_version_profile
  app_connector_group_version_profile_id       = var.app_connector_group_version_profile_id
  app_connector_group_dns_query_type           = var.app_connector_group_dns_query_type
}

module "zpa_provisioning_key" {
  count                             = local.use_provisioning_key ? 1 : 0
  source                            = "../../modules/terraform-zpa-provisioning-key"
  provisioning_key_name             = var.provisioning_key_name != "" ? var.provisioning_key_name : local.custom_ac_group_name
  provisioning_key_enabled          = var.provisioning_key_enabled
  provisioning_key_association_type = var.provisioning_key_association_type
  provisioning_key_max_usage        = var.provisioning_key_max_usage
  app_connector_group_id            = try(module.zpa_app_connector_group_pk[0].app_connector_group_id, "")
  byo_provisioning_key              = var.byo_provisioning_key
  byo_provisioning_key_name         = var.byo_provisioning_key_name
}


################################################################################
# 5. (OAuth2 flow only) SSM Parameter configuration for ASG.
#    Instances create parameters dynamically: {prefix}-{instance-id}.
#    No pre-creation - only running VMs have parameters.
################################################################################
locals {
  ssm_parameter_prefix = var.byo_ssm_parameter_name == "" ? "/zpa/oauth-tokens/${var.name_prefix}-${var.aws_region}-asg-${random_string.suffix.result}" : var.byo_ssm_parameter_name
}


################################################################################
# 6. Generate user_data using centralized scripts (Zscaler AMI or RHEL9 based
#    on use_zscaler_ami). The onboarding_method flag selects between OAuth2 and
#    provisioning key bootstrap logic inside the script.
################################################################################
locals {
  provisioning_key_value = local.use_provisioning_key ? try(module.zpa_provisioning_key[0].provisioning_key, "") : ""

  # Zscaler AMI user_data (for ASG)
  appuserdata = templatefile("${path.module}/../../scripts/user_data_zscaler.sh", {
    onboarding_method    = local.use_provisioning_key ? "provisioning_key" : "oauth"
    provisioning_key     = local.provisioning_key_value
    ssm_parameter_name   = "" # Not used for ASG
    ssm_parameter_prefix = local.ssm_parameter_prefix
    is_asg               = true
  })

  # RHEL9 user_data (for ASG)
  rhel9userdata = templatefile("${path.module}/../../scripts/user_data_rhel9.sh", {
    onboarding_method    = local.use_provisioning_key ? "provisioning_key" : "oauth"
    provisioning_key     = local.provisioning_key_value
    ssm_parameter_name   = "" # Not used for ASG
    ssm_parameter_prefix = local.ssm_parameter_prefix
    is_asg               = true
  })
}




################################################################################
# Locate Latest App Connector AMI by product code
################################################################################
data "aws_ami" "appconnector" {
  count       = var.use_zscaler_ami ? 1 : 0
  most_recent = true

  filter {
    name   = "product-code"
    values = ["by1wc5269g0048ix2nqvr0362"]
  }

  owners = ["aws-marketplace"]
}


################################################################################
# Locate Latest Red Hat Enterprise Linux 9 AMI for instance use
################################################################################
data "aws_ami" "rhel_9_latest" {
  count       = var.use_zscaler_ami ? 0 : 1
  most_recent = true
  owners      = ["309956199498"]

  filter {
    name   = "name"
    values = ["RHEL-9.4.0_HVM-20240423-x86_64-62-Hourly2-GP3"]
  }
}

# Local variable to select the appropriate AMI ID
locals {
  ami_selected = try(data.aws_ami.appconnector[0].id, data.aws_ami.rhel_9_latest[0].id)
}

################################################################################
# 7. Create the specified AC VMs via Launch Template and Autoscaling Group
################################################################################
module "ac_asg" {
  source                      = "../../modules/terraform-zsac-asg-aws"
  name_prefix                 = var.name_prefix
  resource_tag                = random_string.suffix.result
  global_tags                 = local.global_tags
  ac_subnet_ids               = module.network.ac_subnet_ids
  instance_key                = aws_key_pair.deployer.key_name
  user_data                   = var.use_zscaler_ami == true ? local.appuserdata : local.rhel9userdata
  acvm_instance_type          = var.acvm_instance_type
  iam_instance_profile        = module.ac_iam.iam_instance_profile_id
  security_group_id           = module.ac_sg.ac_security_group_id
  associate_public_ip_address = var.associate_public_ip_address
  ami_id                      = contains(var.ami_id, "") ? [local.ami_selected] : var.ami_id

  max_size                  = var.max_size
  min_size                  = var.min_size
  target_cpu_util_value     = var.target_cpu_util_value
  health_check_grace_period = var.health_check_grace_period
  launch_template_version   = var.launch_template_version
  target_tracking_metric    = var.target_tracking_metric

  warm_pool_enabled = var.warm_pool_enabled
  ### only utilzed if warm_pool_enabled set to true ###
  warm_pool_state                       = var.warm_pool_state
  warm_pool_min_size                    = var.warm_pool_min_size
  warm_pool_max_group_prepared_capacity = var.warm_pool_max_group_prepared_capacity
  reuse_on_scale_in                     = var.reuse_on_scale_in
  ### only utilzed if warm_pool_enabled set to true ###

}


################################################################################
# 8. Create IAM Policy, Roles, and Instance Profiles to be assigned to AC.
#    Default behavior will create 1 of each IAM resource per AC VM. Set variable
#    "reuse_iam" to true if you would like a single IAM profile created and
#    assigned to ALL App Connectors instead.
################################################################################
module "ac_iam" {
  source       = "../../modules/terraform-zsac-iam-aws"
  iam_count    = 1
  name_prefix  = var.name_prefix
  resource_tag = random_string.suffix.result
  global_tags  = local.global_tags
}


################################################################################
# 9. Create Security Group and rules to be assigned to the App Connector
#    interface. Default behavior will create 1 of each SG resource per AC VM.
#    Set variable "reuse_security_group" to true if you would like a single
#    security group created and assigned to ALL App Connectors instead.
################################################################################
module "ac_sg" {
  source       = "../../modules/terraform-zsac-sg-aws"
  sg_count     = 1
  name_prefix  = var.name_prefix
  resource_tag = random_string.suffix.result
  global_tags  = local.global_tags
  vpc_id       = module.network.vpc_id
}


################################################################################
# 10. (OAuth2 flow only) Discover the OAuth user codes registered by the ASG
#     instances and feed them to the ZPA App Connector Group.
#
#     The discovery is scoped to THIS stack's ASG (by name) and reads each
#     instance's dedicated SSM parameter ({prefix}-{instance-id}). It paginates
#     via the per-instance parameter name and retries patiently to absorb the
#     boot lag between an instance reaching "running" and the OAuth code
#     becoming available in /etc/issue.
################################################################################
data "external" "asg_oauth_tokens" {
  count = local.use_provisioning_key ? 0 : 1

  program = ["bash", "-c", <<-EOT
    set -o pipefail
    REGION="${var.aws_region}"
    ASG_NAME="${module.ac_asg.autoscaling_group_name}"
    SSM_PREFIX="${local.ssm_parameter_prefix}"

    DESIRED=$(aws autoscaling describe-auto-scaling-groups \
      --auto-scaling-group-names "$ASG_NAME" \
      --query 'AutoScalingGroups[0].DesiredCapacity' \
      --output text --region "$REGION" 2>/dev/null)
    if [ -z "$DESIRED" ] || [ "$DESIRED" = "None" ]; then DESIRED=0; fi
    echo "ASG $ASG_NAME desired capacity: $DESIRED" >&2

    MAX_ATTEMPTS=24   # 24 * 30s = 12 minutes
    ATTEMPT=0
    TOKENS=""

    while [ "$ATTEMPT" -lt "$MAX_ATTEMPTS" ]; do
      INSTANCE_IDS=$(aws autoscaling describe-auto-scaling-groups \
        --auto-scaling-group-names "$ASG_NAME" \
        --query 'AutoScalingGroups[0].Instances[?LifecycleState==`InService`].InstanceId' \
        --output text --region "$REGION" 2>/dev/null)

      TOKENS=""
      FOUND=0
      EXPECTED=0
      for IID in $INSTANCE_IDS; do
        EXPECTED=$((EXPECTED + 1))
        VALUE=$(aws ssm get-parameter \
          --name "$SSM_PREFIX-$IID" \
          --with-decryption \
          --query 'Parameter.Value' \
          --output text --region "$REGION" 2>/dev/null || echo "")
        if printf '%s' "$VALUE" | grep -Eq '^[A-Z0-9]{5}-[A-Z0-9]{5}$'; then
          FOUND=$((FOUND + 1))
          if [ -z "$TOKENS" ]; then TOKENS="$VALUE"; else TOKENS="$TOKENS,$VALUE"; fi
        fi
      done

      echo "Attempt $((ATTEMPT + 1))/$MAX_ATTEMPTS: in-service=$EXPECTED desired=$DESIRED codes=$FOUND" >&2

      if [ "$EXPECTED" -ge "$DESIRED" ] && [ "$DESIRED" -gt 0 ] && [ "$FOUND" -ge "$DESIRED" ]; then
        echo "All OAuth codes retrieved." >&2
        break
      fi

      sleep 30
      ATTEMPT=$((ATTEMPT + 1))
    done

    printf '{"tokens":"%s"}' "$TOKENS"
  EOT
  ]

  depends_on = [module.ac_asg]
}

# Parse codes from the external data source
locals {
  asg_tokens_raw = local.use_provisioning_key ? "" : try(data.external.asg_oauth_tokens[0].result.tokens, "")
  user_codes     = local.use_provisioning_key ? [] : (local.asg_tokens_raw != "" ? split(",", local.asg_tokens_raw) : [])
}


################################################################################
# 11. (OAuth2 flow only) Create the ZPA App Connector Group with OAuth2 user
#     codes from the ASG instances that successfully registered.
################################################################################
module "zpa_app_connector_group" {
  count                                        = local.use_provisioning_key ? 0 : 1
  source                                       = "../../modules/terraform-zpa-app-connector-group"
  app_connector_group_name                     = local.custom_ac_group_name
  app_connector_group_description              = "${var.app_connector_group_description}-${var.aws_region}-${module.network.vpc_id}"
  app_connector_group_enabled                  = var.app_connector_group_enabled
  app_connector_group_country_code             = var.app_connector_group_country_code
  app_connector_group_city_country             = var.app_connector_group_city_country
  app_connector_group_latitude                 = var.app_connector_group_latitude
  app_connector_group_longitude                = var.app_connector_group_longitude
  app_connector_group_location                 = var.app_connector_group_location
  app_connector_group_upgrade_day              = var.app_connector_group_upgrade_day
  app_connector_group_upgrade_time_in_secs     = var.app_connector_group_upgrade_time_in_secs
  app_connector_group_override_version_profile = var.app_connector_group_override_version_profile
  app_connector_group_version_profile_id       = var.app_connector_group_version_profile_id
  app_connector_group_dns_query_type           = var.app_connector_group_dns_query_type
  user_codes                                   = local.user_codes

  depends_on = [
    data.external.asg_oauth_tokens
  ]
}
