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
    Module      = "terraform-zsac-acvm-aws"
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
    Module      = "terraform-zsac-acvm-aws"
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
    Module      = "terraform-zsac-acvm-aws"
  }
  iam_count                   = 2
  byo_iam                     = false
  byo_iam_instance_profile_id = []
}

################################################################################
# Test Module - ACVM Infrastructure
################################################################################
module "acvm" {
  source = "../../modules/terraform-zsac-acvm-aws"

  # Required parameters
  name_prefix  = local.name_prefix
  resource_tag = local.resource_tag
  global_tags = {
    Environment = "test"
    Purpose     = "terratest"
    Module      = "terraform-zsac-acvm-aws"
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
  ac_count           = var.ac_count

  # Optional parameters
  associate_public_ip_address = var.associate_public_ip_address
  imdsv2_enabled              = var.imdsv2_enabled
}

# Test outputs - these validate the module is working correctly
output "private_ip" {
  description = "ACVM Private IP Addresses from module"
  value       = module.acvm.private_ip
}

output "availability_zone" {
  description = "ACVM Availability Zones from module"
  value       = module.acvm.availability_zone
}

output "id" {
  description = "ACVM Instance IDs from module"
  value       = module.acvm.id
}

output "public_ip" {
  description = "ACVM Public IP Addresses from module"
  value       = module.acvm.public_ip
}

output "private_ip_valid" {
  description = "Validation that Private IP is valid"
  value       = length(module.acvm.private_ip) > 0 ? "true" : "false"
}

output "availability_zone_valid" {
  description = "Validation that Availability Zone is valid"
  value       = length(module.acvm.availability_zone) > 0 ? "true" : "false"
}

output "instance_id_valid" {
  description = "Validation that Instance ID is valid"
  value       = length(module.acvm.id) > 0 ? "true" : "false"
}

output "test_variables_set_correctly" {
  description = "Validation that test variables are set correctly"
  value       = var.name_prefix != "" && var.resource_tag != "" ? "true" : "false"
}

output "acvm_configuration_valid" {
  description = "Validation that ACVM configuration is valid"
  value       = var.ac_count > 0 ? "true" : "false"
}

output "instance_type_valid" {
  description = "Validation that instance type is valid"
  value       = var.acvm_instance_type != "" ? "true" : "false"
}

output "network_dependencies_valid" {
  description = "Validation that network dependencies are valid"
  value       = length(module.network.ac_subnet_ids) >= 2 && length(module.security_groups.ac_security_group_id) >= 2 && length(module.iam.iam_instance_profile_id) >= 2 ? "true" : "false"
}
