# 0. Random
resource "random_string" "suffix" {
  length  = 8
  upper   = false
  special = false
}

module "security_vpc" {
  source = "../../modules/vpc"

  name                    = var.security_vpc_name
  cidr_block              = var.security_vpc_cidr
  security_groups         = var.security_vpc_security_groups
  create_internet_gateway = true
  enable_dns_hostnames    = true
  enable_dns_support      = true
  instance_tenancy        = "default"
}

module "security_subnet_sets" {
  source = "../../modules/subnet_set"

  for_each = toset(distinct([for _, v in var.security_vpc_subnets : v.set]))

  name                = each.key
  vpc_id              = module.security_vpc.id
  has_secondary_cidrs = module.security_vpc.has_secondary_cidrs
  cidrs               = { for k, v in var.security_vpc_subnets : k => v if v.set == each.key }
}

module "natgw_set" {
  # This also a "set" and it means the same thing: we will repeat a nat gateway for each subnet (of the subnet_set).
  source = "../../modules/nat_gateway_set"

  subnets = module.security_subnet_sets["natgw"].subnets
}

module "appconnector-vm" {
  for_each = var.appconnector-vm
  source   = "../../modules/zpa-appconnector-vm"

  name                 = var.name
  ssh_key_name         = var.ssh_key_name
  bootstrap_options    = var.bootstrap_options
  iam_instance_profile = var.iam_instance_profile
  appconnector_version = var.appconnector_version
  interfaces = {
    mgmt = {
      device_index       = 0
      security_group_ids = [module.security_vpc.security_group_ids["zpa_app_connector_mgmt"]]
      source_dest_check  = false
      subnet_id          = module.security_subnet_sets["mgmt"].subnets[each.value.az].id
      create_public_ip   = true
    }
  }

  tags                 = var.global_tags
  path_to_public_key   = var.path_to_public_key
}

locals {
  security_vpc_routes = concat(
    [for cidr in var.security_vpc_routes_outbound_destin_cidrs :
      {
        subnet_key   = "mgmt"
        # next_hop_set = module.natgw_set.next_hop_set
        next_hop_set = module.security_vpc.igw_as_next_hop_set
        to_cidr      = cidr
      }
    ],
        [for cidr in var.security_vpc_routes_outbound_destin_cidrs :
      {
        subnet_key   = "natgw"
        next_hop_set = module.security_vpc.igw_as_next_hop_set
        to_cidr      = cidr
      }
    ],
  )
}

module "security_vpc_routes" {
  for_each = { for route in local.security_vpc_routes : "${route.subnet_key}_${route.to_cidr}" => route }
  source   = "../../modules/vpc_route"

  route_table_ids = module.security_subnet_sets[each.value.subnet_key].unique_route_table_ids
  to_cidr         = each.value.to_cidr
  next_hop_set    = each.value.next_hop_set
}

module "zpa_app_connector_group" {
  source = "../../modules/zpa_app_connector_group"

  app_connector_group_name                 = "ZSAC-${var.region}-${module.security_vpc.id}"
  app_connector_group_description          = "ZSAC-${var.region}-${module.security_vpc.id}"
  app_connector_group_enabled              = var.app_connector_group_enabled
  app_connector_group_country_code         = var.app_connector_group_country_code
  app_connector_group_latitude             = var.app_connector_group_latitude
  app_connector_group_longitude            = var.app_connector_group_longitude
  app_connector_group_location             = var.app_connector_group_location
  app_connector_group_upgrade_day          = var.app_connector_group_upgrade_day
  app_connector_group_upgrade_time_in_secs = var.app_connector_group_upgrade_time_in_secs
  app_connector_group_version_profile_id   = var.app_connector_group_version_profile_id
  app_connector_group_dns_query_type       = var.app_connector_group_dns_query_type

  provisioning_key_name             = "ZSAC-${var.region}-${module.security_vpc.id}"
  provisioning_key_association_type = var.provisioning_key_association_type
  provisioning_key_max_usage        = var.provisioning_key_max_usage
}

# Create Parameter Store
resource "aws_ssm_parameter" "this" {
  name = "ZSAC-${var.region}-${module.security_vpc.id}"
  description = "ZSAC-${var.region}-${module.security_vpc.id}"
  type        = "SecureString"
  value       = module.zpa_app_connector_group.provisioning_key
  key_id      = aws_kms_key.this.key_id
  overwrite   = true
  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}

# Create an alias to the key
resource "aws_kms_alias" "this" {
  name          = "alias/${var.kms_alias}-zpa-kms-${random_string.suffix.result}"
  target_key_id = aws_kms_key.this.key_id
}

# Creates/manages KMS CMK
resource "aws_kms_key" "this" {
  description              = var.description
  customer_master_key_spec = var.key_spec
  deletion_window_in_days  = var.deletion_window_in_days
  is_enabled               = var.is_enabled
  enable_key_rotation      = var.rotation_enabled
  multi_region             = var.multi_region
}