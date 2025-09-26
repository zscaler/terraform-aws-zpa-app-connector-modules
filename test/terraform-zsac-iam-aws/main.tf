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

locals {
  name_prefix  = "${var.name_prefix}-${random_pet.this.id}"
  resource_tag = var.resource_tag
}

################################################################################
# Test Module - IAM Infrastructure
################################################################################
module "iam" {
  source = "../../modules/terraform-zsac-iam-aws"

  # Required parameters
  name_prefix  = local.name_prefix
  resource_tag = local.resource_tag

  # Optional parameters
  global_tags = {
    Environment = "test"
    Purpose     = "terratest"
    Module      = "terraform-zsac-iam-aws"
  }
  iam_count                   = var.iam_count
  byo_iam                     = var.byo_iam
  byo_iam_instance_profile_id = var.byo_iam_instance_profile_id
}

# Test outputs - these validate the module is working correctly
output "iam_instance_profile_id" {
  description = "IAM Instance Profile ID from module"
  value       = module.iam.iam_instance_profile_id
}

output "iam_instance_profile_arn" {
  description = "IAM Instance Profile ARN from module"
  value       = module.iam.iam_instance_profile_arn
}

output "iam_instance_profile_id_valid" {
  description = "Validation that IAM Instance Profile ID is valid"
  value       = length(module.iam.iam_instance_profile_id) > 0 ? "true" : "false"
}

output "iam_instance_profile_arn_valid" {
  description = "Validation that IAM Instance Profile ARN is valid"
  value       = length(module.iam.iam_instance_profile_arn) > 0 ? "true" : "false"
}

output "iam_instance_profile_count_correct" {
  description = "Validation that IAM Instance Profile count is correct"
  value       = length(module.iam.iam_instance_profile_id) == var.iam_count ? "true" : "false"
}

output "iam_instance_profile_arn_count_correct" {
  description = "Validation that IAM Instance Profile ARN count is correct"
  value       = length(module.iam.iam_instance_profile_arn) == var.iam_count ? "true" : "false"
}

output "test_variables_set_correctly" {
  description = "Validation that test variables are set correctly"
  value       = var.name_prefix != "" && var.resource_tag != "" ? "true" : "false"
}

output "iam_count_correct" {
  description = "Validation that IAM count is correct"
  value       = var.iam_count >= 1 ? "true" : "false"
}

output "byo_iam_set_correctly" {
  description = "Validation that BYO IAM is set correctly"
  value       = var.byo_iam == false ? "true" : "false"
}
