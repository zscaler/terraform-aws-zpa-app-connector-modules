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
    Module      = "terraform-zsac-bastion-aws"
  }
}

################################################################################
# Test Module - Bastion Infrastructure
################################################################################
module "bastion" {
  source = "../../modules/terraform-zsac-bastion-aws"

  # Required parameters
  name_prefix  = local.name_prefix
  resource_tag = local.resource_tag
  global_tags = {
    Environment = "test"
    Purpose     = "terratest"
    Module      = "terraform-zsac-bastion-aws"
  }

  # Network configuration
  vpc_id        = module.network.vpc_id
  public_subnet = module.network.public_subnet_ids[0]

  # Instance configuration
  instance_key  = aws_key_pair.test_key.key_name
  instance_type = var.instance_type

  # Security configuration
  bastion_nsg_source_prefix = var.bastion_nsg_source_prefix

  # IAM configuration
  iam_role_policy_ssmcore = var.iam_role_policy_ssmcore
}

# Test outputs - these validate the module is working correctly
output "public_ip" {
  description = "Bastion Host Public IP from module"
  value       = module.bastion.public_ip
}

output "public_dns" {
  description = "Bastion Host Public DNS from module"
  value       = module.bastion.public_dns
}

output "public_ip_valid" {
  description = "Validation that Public IP is valid"
  value       = module.bastion.public_ip != null && module.bastion.public_ip != "" ? "true" : "false"
}

output "public_dns_valid" {
  description = "Validation that Public DNS is valid"
  value       = module.bastion.public_dns != null && module.bastion.public_dns != "" ? "true" : "false"
}

output "test_variables_set_correctly" {
  description = "Validation that test variables are set correctly"
  value       = var.name_prefix != "" && var.resource_tag != "" ? "true" : "false"
}

output "instance_type_valid" {
  description = "Validation that instance type is valid"
  value       = var.instance_type != "" ? "true" : "false"
}

output "network_dependencies_valid" {
  description = "Validation that network dependencies are valid"
  value       = module.network.vpc_id != "" && length(module.network.public_subnet_ids) > 0 ? "true" : "false"
}
