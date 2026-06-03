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
  #bring-your-own variables
  byo_vpc        = var.byo_vpc
  byo_vpc_id     = var.byo_vpc_id
  byo_subnets    = var.byo_subnets
  byo_subnet_ids = var.byo_subnet_ids
  byo_igw        = var.byo_igw
  byo_igw_id     = var.byo_igw_id
  byo_ngw        = var.byo_ngw
  byo_ngw_ids    = var.byo_ngw_ids
}


################################################################################
# 2. SSM Parameter configuration for ASG
#    VMs create parameters dynamically: {prefix}-{instance-id}
#    No pre-creation - only running VMs have parameters
################################################################################
locals {
  ssm_parameter_prefix = var.byo_ssm_parameter_name == "" ? "/zpa/oauth-tokens/${var.name_prefix}-${var.aws_region}-asg" : var.byo_ssm_parameter_name
}


################################################################################
# 3. Create specified number AC VMs per min_size / max_size which will span
#    equally across designated availability zones per az_count. E.g. min_size
#    set to 4 and az_count set to 2 will create 2x ACs in AZ1 and 2x ACs in AZ2
################################################################################

################################################################################
# Generate user_data using centralized scripts
# Zscaler AMI or RHEL9 based on use_zscaler_ami variable
################################################################################
locals {
  # Zscaler AMI user_data (for ASG)
  appuserdata = templatefile("${path.module}/../../scripts/user_data_zscaler.sh", {
    ssm_parameter_name   = "" # Not used for ASG
    ssm_parameter_prefix = local.ssm_parameter_prefix
    is_asg               = true
  })

  # RHEL9 user_data (for ASG)
  rhel9userdata = templatefile("${path.module}/../../scripts/user_data_rhel9.sh", {
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

# Data source to retrieve RHEL 9.4.0 AMI
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
# Create the specified AC VMs via Launch Template and Autoscaling Group
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
# 5. Create IAM Policy, Roles, and Instance Profiles to be assigned to AC.
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

  byo_iam = var.byo_iam
  # optional inputs. only required if byo_iam set to true
  byo_iam_instance_profile_id = var.byo_iam_instance_profile_id
  # optional inputs. only required if byo_iam set to true
}


################################################################################
# 6. Create Security Group and rules to be assigned to the App Connector
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

  byo_security_group = var.byo_security_group
  # optional inputs. only required if byo_security_group set to true
  byo_security_group_id = var.byo_security_group_id
  # optional inputs. only required if byo_security_group set to true
}


################################################################################
# 7. Wait for ASG instances to launch and register OAuth tokens
################################################################################
resource "time_sleep" "wait_for_asg_instances" {
  depends_on = [module.ac_asg]

  create_duration = "480s" # 8 minutes for ASG instances to launch and register tokens
}


################################################################################
# 8. Discover running ASG instances and retrieve their OAuth tokens from SSM
################################################################################

# Use external data source to find ALL OAuth tokens in SSM (don't rely on instance discovery)
data "external" "asg_oauth_tokens" {
  program = ["bash", "-c", <<-EOT
    # Get number of running instances
    INSTANCE_COUNT=$(aws ec2 describe-instances \
      --filters "Name=tag:Name,Values=*-acvm-asg-*" "Name=instance-state-name,Values=running" \
      --query 'length(Reservations[*].Instances[*])' \
      --output text \
      --region ${var.aws_region})
    
    echo "Expected instances: $INSTANCE_COUNT" >&2
    
    # Poll until we have tokens for all instances (max 20 attempts, 30s each = 10 min)
    MAX_ATTEMPTS=20
    ATTEMPT=0
    
    while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
      TOKENS=""
      
      # List all SSM parameters matching our prefix
      PARAMS=$(aws ssm describe-parameters \
        --region ${var.aws_region} \
        --query 'Parameters[?contains(Name, `${local.ssm_parameter_prefix}-i`)].Name' \
        --output text)
      
      # Read each parameter and collect valid OAuth tokens
      for param in $PARAMS; do
        TOKEN=$(aws ssm get-parameter \
          --name "$param" \
          --with-decryption \
          --query 'Parameter.Value' \
          --output text \
          --region ${var.aws_region} 2>/dev/null || echo "")
        
        # Only include if it matches OAuth token format
        if [[ "$TOKEN" =~ ^[A-Z0-9]{5}-[A-Z0-9]{5}$ ]]; then
          if [ -z "$TOKENS" ]; then
            TOKENS="$TOKEN"
          else
            TOKENS="$TOKENS,$TOKEN"
          fi
        fi
      done
      
      # Count tokens
      if [ -z "$TOKENS" ]; then
        TOKEN_COUNT=0
      else
        TOKEN_COUNT=$(echo "$TOKENS" | tr ',' '\n' | wc -l)
      fi
      
      echo "Attempt $((ATTEMPT + 1))/$MAX_ATTEMPTS: Found $TOKEN_COUNT tokens, expecting $INSTANCE_COUNT" >&2
      
      # If we have all tokens, exit
      if [ "$TOKEN_COUNT" -ge "$INSTANCE_COUNT" ]; then
        echo "All tokens retrieved!" >&2
        echo "{\"tokens\": \"$TOKENS\"}"
        exit 0
      fi
      
      # Wait and retry
      sleep 30
      ATTEMPT=$((ATTEMPT + 1))
    done
    
    # Return what we have even if not all
    echo "Timeout: Only found $TOKEN_COUNT of $INSTANCE_COUNT tokens" >&2
    echo "{\"tokens\": \"$TOKENS\"}"
  EOT
  ]

  depends_on = [time_sleep.wait_for_asg_instances]
}

# Parse tokens from external data source
locals {
  user_codes = data.external.asg_oauth_tokens.result.tokens != "" ? split(",", data.external.asg_oauth_tokens.result.tokens) : []
}


################################################################################
# 9. Retrieve ZPA Enrollment Certificate ID
################################################################################
data "zpa_enrollment_cert" "connector_cert" {
  name = var.enrollment_cert
}


################################################################################
# 10. Generate App Connector Group name with template variable support
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
# 11. Create ZPA App Connector Group with OAuth2 User Codes
#     Uses tokens from ASG instances that successfully registered
################################################################################
module "zpa_app_connector_group" {
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
  enrollment_cert_id                           = data.zpa_enrollment_cert.connector_cert.id
  user_codes                                   = local.user_codes

  depends_on = [
    data.external.asg_oauth_tokens
  ]
}
