################################################################################
# AWS Provider Configuration
################################################################################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.94.0"
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
