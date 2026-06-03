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
# 3. Create SSM Parameter Store parameters for OAuth token storage
#    Terraform creates these upfront, VMs will update them with actual tokens
################################################################################
resource "aws_ssm_parameter" "oauth_tokens" {
  count = var.byo_ssm_parameter_name == "" ? var.ac_count : 0

  name  = "/zpa/oauth-tokens/${var.name_prefix}-${var.aws_region}-ac-${count.index + 1}-${random_string.suffix.result}"
  type  = "SecureString"
  value = "PENDING" # Placeholder - will be updated by VM user_data

  tags = merge(local.global_tags, {
    Purpose = "ZPA-OAuth-Token"
    VMIndex = count.index
  })

  lifecycle {
    ignore_changes = [
      value, # VM will update this, so ignore changes from Terraform
    ]
  }
}

# Or use existing parameters if BYO is specified
locals {
  ssm_parameter_names = var.byo_ssm_parameter_name == "" ? aws_ssm_parameter.oauth_tokens[*].name : [for i in range(var.ac_count) : "${var.byo_ssm_parameter_name}-${i}"]
}


################################################################################
# 4. Create specified number AC VMs per ac_count which will span equally across
#    designated availability zones per az_count. E.g. ac_count set to 4 and
#    az_count set to 2 will create 2x ACs in AZ1 and 2x ACs in AZ2
################################################################################

################################################################################
# Generate user_data using centralized scripts
# Zscaler AMI or RHEL9 based on use_zscaler_ami variable
################################################################################
locals {
  # Zscaler AMI user_data (for Fixed VMs)
  appuserdata = [for i in range(var.ac_count) :
    templatefile("${path.module}/../../scripts/user_data_zscaler.sh", {
      ssm_parameter_name   = local.ssm_parameter_names[i]
      ssm_parameter_prefix = "" # Not used for fixed VMs
      is_asg               = false
    })
  ]

  # RHEL9 user_data (for Fixed VMs)
  rhel9userdata = [for i in range(var.ac_count) :
    templatefile("${path.module}/../../scripts/user_data_rhel9.sh", {
      ssm_parameter_name   = local.ssm_parameter_names[i]
      ssm_parameter_prefix = "" # Not used for fixed VMs
      is_asg               = false
    })
  ]
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

locals {
  ami_selected = try(data.aws_ami.appconnector[0].id, data.aws_ami.rhel_9_latest[0].id)
}

################################################################################
# Create specified number of AC appliances
################################################################################
module "ac_vm" {
  source                      = "../../modules/terraform-zsac-acvm-aws"
  ac_count                    = var.ac_count
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

  depends_on = [
    aws_ssm_parameter.oauth_tokens
  ]
}


################################################################################
# 5. Create IAM Policy, Roles, and Instance Profiles to be assigned to AC.
#    Default behavior will create 1 of each IAM resource per AC VM. Set variable
#    "reuse_iam" to true if you would like a single IAM profile created and
#    assigned to ALL App Connectors instead.
################################################################################
module "ac_iam" {
  source       = "../../modules/terraform-zsac-iam-aws"
  iam_count    = var.reuse_iam == false ? var.ac_count : 1
  name_prefix  = var.name_prefix
  resource_tag = random_string.suffix.result
  global_tags  = local.global_tags
}


################################################################################
# 6. Create Security Group and rules to be assigned to the App Connector
#    interface. Default behavior will create 1 of each SG resource per AC VM.
#    Set variable "reuse_security_group" to true if you would like a single
#    security group created and assigned to ALL App Connectors instead.
################################################################################
module "ac_sg" {
  source       = "../../modules/terraform-zsac-sg-aws"
  sg_count     = var.reuse_security_group == false ? var.ac_count : 1
  name_prefix  = var.name_prefix
  resource_tag = random_string.suffix.result
  global_tags  = local.global_tags
  vpc_id       = module.network.vpc_id
}


################################################################################
# 7. Wait for OAuth Tokens with Simple Fixed Delay
#    VMs register tokens quickly (2-4 min), then Terraform reads them
################################################################################

# Wait for OAuth tokens to be registered in SSM
resource "time_sleep" "wait_for_oauth_tokens" {
  depends_on = [module.ac_vm]

  create_duration = "360s" # 6 minutes - ensures both VMs have time to register
}

# Retrieve OAuth tokens from SSM Parameter Store
data "aws_ssm_parameter" "oauth_tokens" {
  count      = var.ac_count
  name       = local.ssm_parameter_names[count.index]
  depends_on = [time_sleep.wait_for_oauth_tokens, aws_ssm_parameter.oauth_tokens]
}

# Extract tokens from SSM parameters
locals {
  user_codes = [for i in range(var.ac_count) : data.aws_ssm_parameter.oauth_tokens[i].value]
}


################################################################################
# 8. Retrieve ZPA Enrollment Certificate ID
################################################################################
data "zpa_enrollment_cert" "connector_cert" {
  name = var.enrollment_cert
}


################################################################################
# 9. Generate App Connector Group name with template variable support
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
# 10. Create ZPA App Connector Group with OAuth2 User Codes
#     Created AFTER waiting for all OAuth tokens to be ready
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
    data.aws_ssm_parameter.oauth_tokens
  ]
}
