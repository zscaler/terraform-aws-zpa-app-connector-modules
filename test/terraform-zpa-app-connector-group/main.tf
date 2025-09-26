################################################################################
# ZPA Provider Configuration
################################################################################
terraform {
  required_providers {
    zpa = {
      source = "zscaler/zpa"
    }
  }
  required_version = ">= 0.13.7, < 2.0.0"
}

# Configure the ZPA Provider
provider "zpa" {
  # ZPA provider configuration will be set via environment variables:
  # ZPA_CLIENT_ID, ZPA_CLIENT_SECRET, ZPA_CUSTOMER_ID, ZPA_CLOUD
}

################################################################################
# Test Module - App Connector Group
################################################################################
module "zpa_app_connector_group" {
  source = "../../modules/terraform-zpa-app-connector-group"

  # Required parameters
  app_connector_group_name      = var.app_connector_group_name
  app_connector_group_latitude  = var.app_connector_group_latitude
  app_connector_group_longitude = var.app_connector_group_longitude
  app_connector_group_location  = var.app_connector_group_location

  # Optional parameters
  app_connector_group_description              = var.app_connector_group_description
  app_connector_group_enabled                  = var.app_connector_group_enabled
  app_connector_group_country_code             = var.app_connector_group_country_code
  app_connector_group_upgrade_day              = var.app_connector_group_upgrade_day
  app_connector_group_upgrade_time_in_secs     = var.app_connector_group_upgrade_time_in_secs
  app_connector_group_override_version_profile = var.app_connector_group_override_version_profile
  app_connector_group_version_profile_id       = var.app_connector_group_version_profile_id
  app_connector_group_dns_query_type           = var.app_connector_group_dns_query_type
}

# Test outputs - these validate the module is working correctly
output "app_connector_group_id" {
  description = "ZPA App Connector Group ID from module"
  value       = module.zpa_app_connector_group.app_connector_group_id
}

output "app_connector_group_id_valid" {
  description = "Validation that App Connector Group ID is valid"
  value       = length(module.zpa_app_connector_group.app_connector_group_id) > 0 ? "true" : "false"
}

output "test_variables_set_correctly" {
  description = "Validation that test variables are set correctly"
  value       = var.app_connector_group_name != "" && var.app_connector_group_location != "" ? "true" : "false"
}
