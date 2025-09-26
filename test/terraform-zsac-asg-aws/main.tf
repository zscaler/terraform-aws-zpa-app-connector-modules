################################################################################
# AWS Provider Configuration
################################################################################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0, ~> 5.94.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.0"
    }
  }
  required_version = ">= 0.13.7, < 2.0.0"
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Random name allows parallel runs on the same cloud account
resource "random_pet" "this" {
  prefix = var.name_prefix
  length = 2
}

# Create temporary SSH key pair for testing
resource "tls_private_key" "test_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "test_key" {
  key_name   = "test-key-${random_pet.this.id}"
  public_key = tls_private_key.test_key.public_key_openssh
}

locals {
  name_prefix  = "${var.name_prefix}-${random_pet.this.id}"
  resource_tag = var.resource_tag
}

################################################################################
# Test Infrastructure - Network
################################################################################
module "network" {
  source = "../../modules/terraform-zsac-network-aws"

  name_prefix  = local.name_prefix
  resource_tag = local.resource_tag
  global_tags = {
    Environment = "test"
    Purpose     = "terratest"
    Module      = "terraform-zsac-asg-aws"
  }
}

################################################################################
# Test Infrastructure - Security Groups
################################################################################
module "security_groups" {
  source = "../../modules/terraform-zsac-sg-aws"

  name_prefix  = local.name_prefix
  resource_tag = local.resource_tag
  global_tags = {
    Environment = "test"
    Purpose     = "terratest"
    Module      = "terraform-zsac-asg-aws"
  }
  vpc_id                = module.network.vpc_id
  sg_count              = 2
  byo_security_group    = false
  byo_security_group_id = []
}

################################################################################
# Test Infrastructure - IAM
################################################################################
module "iam" {
  source = "../../modules/terraform-zsac-iam-aws"

  name_prefix  = local.name_prefix
  resource_tag = local.resource_tag
  global_tags = {
    Environment = "test"
    Purpose     = "terratest"
    Module      = "terraform-zsac-asg-aws"
  }
  iam_count                   = 2
  byo_iam                     = false
  byo_iam_instance_profile_id = []
}

################################################################################
# Test Module - ASG Infrastructure
################################################################################
module "asg" {
  source = "../../modules/terraform-zsac-asg-aws"

  # Required parameters
  name_prefix  = local.name_prefix
  resource_tag = local.resource_tag
  global_tags = {
    Environment = "test"
    Purpose     = "terratest"
    Module      = "terraform-zsac-asg-aws"
  }

  # Network configuration
  ac_subnet_ids        = module.network.ac_subnet_ids
  security_group_id    = module.security_groups.ac_security_group_id
  iam_instance_profile = module.iam.iam_instance_profile_id

  # Instance configuration
  instance_key       = aws_key_pair.test_key.key_name
  user_data          = var.user_data
  acvm_instance_type = var.acvm_instance_type
  ami_id             = var.ami_id

  # ASG configuration
  min_size                  = var.min_size
  max_size                  = var.max_size
  health_check_grace_period = var.health_check_grace_period

  # EBS configuration
  ebs_block_device_name = var.ebs_block_device_name
  ebs_encrypted         = var.ebs_encrypted
  ebs_kms_key_arn       = var.ebs_kms_key_arn
  ebs_volume_type       = var.ebs_volume_type

  # Autoscaling configuration
  target_tracking_metric = var.target_tracking_metric
  target_cpu_util_value  = var.target_cpu_util_value

  # IMDSv2 configuration
  imdsv2_enabled   = var.imdsv2_enabled
  metadata_options = var.metadata_options

  # Optional parameters
  associate_public_ip_address           = var.associate_public_ip_address
  warm_pool_enabled                     = var.warm_pool_enabled
  warm_pool_state                       = var.warm_pool_state
  warm_pool_min_size                    = var.warm_pool_min_size
  warm_pool_max_group_prepared_capacity = var.warm_pool_max_group_prepared_capacity
  reuse_on_scale_in                     = var.reuse_on_scale_in
  launch_template_version               = var.launch_template_version
}

# Test outputs - these validate the module is working correctly
output "availability_zone" {
  description = "ASG Availability Zones from module"
  value       = module.asg.availability_zone
}

output "availability_zone_valid" {
  description = "Validation that Availability Zone is valid"
  value       = length(module.asg.availability_zone) > 0 ? "true" : "false"
}

output "test_variables_set_correctly" {
  description = "Validation that test variables are set correctly"
  value       = var.name_prefix != "" && var.resource_tag != "" ? "true" : "false"
}

output "asg_configuration_valid" {
  description = "Validation that ASG configuration is valid"
  value       = var.min_size <= var.max_size ? "true" : "false"
}

output "instance_type_valid" {
  description = "Validation that instance type is valid"
  value       = var.acvm_instance_type != "" ? "true" : "false"
}

output "network_dependencies_valid" {
  description = "Validation that network dependencies are valid"
  value       = length(module.network.ac_subnet_ids) >= 2 && length(module.security_groups.ac_security_group_id) >= 2 && length(module.iam.iam_instance_profile_id) >= 2 ? "true" : "false"
}
