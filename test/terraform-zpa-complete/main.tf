terraform {
  required_providers {
    zpa = {
      source = "zscaler/zpa"
    }
  }
}

provider "zpa" {
}

module "app_connector_group" {
  source = "../../modules/terraform-zpa-app-connector-group"

  app_connector_group_name                     = var.app_connector_group_name
  app_connector_group_description              = var.app_connector_group_description
  app_connector_group_enabled                  = var.app_connector_group_enabled
  app_connector_group_country_code             = var.app_connector_group_country_code
  app_connector_group_latitude                 = var.app_connector_group_latitude
  app_connector_group_longitude                = var.app_connector_group_longitude
  app_connector_group_location                 = var.app_connector_group_location
  app_connector_group_upgrade_day              = var.app_connector_group_upgrade_day
  app_connector_group_upgrade_time_in_secs     = var.app_connector_group_upgrade_time_in_secs
  app_connector_group_override_version_profile = var.app_connector_group_override_version_profile
  app_connector_group_version_profile_id       = var.app_connector_group_version_profile_id
  app_connector_group_dns_query_type           = var.app_connector_group_dns_query_type
}

module "provisioning_key" {
  source = "../../modules/terraform-zpa-provisioning-key"

  provisioning_key_name             = var.provisioning_key_name
  provisioning_key_enabled          = var.provisioning_key_enabled
  provisioning_key_association_type = var.provisioning_key_association_type
  provisioning_key_max_usage        = var.provisioning_key_max_usage
  app_connector_group_id            = module.app_connector_group.app_connector_group_id
  byo_provisioning_key              = var.byo_provisioning_key
  byo_provisioning_key_name         = var.byo_provisioning_key_name
  enrollment_cert                   = var.enrollment_cert
}

# Test outputs - these validate the modules are working correctly
output "app_connector_group_id" {
  description = "ZPA App Connector Group ID from module"
  value       = module.app_connector_group.app_connector_group_id
}

output "provisioning_key" {
  description = "ZPA Provisioning Key from module"
  value       = module.provisioning_key.provisioning_key
  sensitive   = true
}
