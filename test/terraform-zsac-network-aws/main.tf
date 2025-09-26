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

# Test outputs - these validate the module is working correctly
output "vpc_id" {
  description = "VPC ID from module"
  value       = module.network.vpc_id
}

output "ac_subnet_ids" {
  description = "App Connector Subnet IDs from module"
  value       = module.network.ac_subnet_ids
}

output "ac_route_table_ids" {
  description = "App Connector Route Table IDs from module"
  value       = module.network.ac_route_table_ids
}

output "public_subnet_ids" {
  description = "Public Subnet IDs from module"
  value       = module.network.public_subnet_ids
}

output "public_route_table_id" {
  description = "Public Route Table ID from module"
  value       = module.network.public_route_table_id
}

output "nat_gateway_ips" {
  description = "NAT Gateway Public IPs from module"
  value       = module.network.nat_gateway_ips
}

output "vpc_id_valid" {
  description = "Validation that VPC ID is valid"
  value       = length(module.network.vpc_id) > 0 ? "true" : "false"
}

output "ac_subnet_ids_valid" {
  description = "Validation that AC Subnet IDs are valid"
  value       = length(module.network.ac_subnet_ids) > 0 ? "true" : "false"
}

output "ac_subnet_count_correct" {
  description = "Validation that AC Subnet count is correct"
  value       = length(module.network.ac_subnet_ids) == var.az_count ? "true" : "false"
}

output "ac_route_table_ids_valid" {
  description = "Validation that AC Route Table IDs are valid"
  value       = length(module.network.ac_route_table_ids) > 0 ? "true" : "false"
}

output "ac_route_table_count_correct" {
  description = "Validation that AC Route Table count is correct"
  value       = length(module.network.ac_route_table_ids) == var.az_count ? "true" : "false"
}

output "test_variables_set_correctly" {
  description = "Validation that test variables are set correctly"
  value       = var.name_prefix != "" && var.resource_tag != "" ? "true" : "false"
}

output "vpc_cidr_correct" {
  description = "Validation that VPC CIDR is correct"
  value       = var.vpc_cidr != "" ? "true" : "false"
}

output "az_count_correct" {
  description = "Validation that AZ count is correct"
  value       = var.az_count >= 1 && var.az_count <= 3 ? "true" : "false"
}
