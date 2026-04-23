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

# Get latest Amazon Linux 2023 AMI from SSM Parameter Store
data "aws_ssm_parameter" "amazon_linux_latest" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
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
  ami_id             = [data.aws_ssm_parameter.amazon_linux_latest.value]
  ac_count           = var.ac_count

  # Optional parameters
  associate_public_ip_address = var.associate_public_ip_address
  imdsv2_enabled              = var.imdsv2_enabled
}
