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
  prefix = "test-network"
}

locals {
  name_prefix  = "test-network-${random_pet.this.id}"
  resource_tag = random_pet.this.id
}

################################################################################
# Test Module - Network Infrastructure
################################################################################
module "network" {
  source = "../../modules/terraform-zsac-network-aws"

  # Required parameters
  name_prefix  = local.name_prefix
  resource_tag = local.resource_tag

  # Optional parameters
  global_tags = {
    Environment = "test"
    Purpose     = "terratest"
    Module      = "terraform-zsac-network-aws"
  }
  vpc_cidr                    = var.vpc_cidr
  az_count                    = var.az_count
  associate_public_ip_address = var.associate_public_ip_address
  byo_vpc                     = var.byo_vpc
  byo_vpc_id                  = var.byo_vpc_id
  byo_igw                     = var.byo_igw
  byo_igw_id                  = var.byo_igw_id
  byo_ngw                     = var.byo_ngw
  byo_ngw_ids                 = var.byo_ngw_ids
  byo_subnets                 = var.byo_subnets
  byo_subnet_ids              = var.byo_subnet_ids
  public_subnets              = var.public_subnets
  ac_subnets                  = var.ac_subnets
}
