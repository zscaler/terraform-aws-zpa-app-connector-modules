terraform {
  required_providers {
    zpa = {
      version = "4.3.81"
      source  = "zscaler.com/zpa/zpa"
    }
  }
  required_version = ">= 0.13.7, < 2.0.0"
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
  enrollment_cert_id                           = data.zpa_enrollment_cert.connector_cert.id
  user_codes                                   = []
}

# Retrieve enrollment certificate for OAuth2
data "zpa_enrollment_cert" "connector_cert" {
  name = var.enrollment_cert
}

# Update module to use OAuth2
module "app_connector_group_oauth2" {
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

  # OAuth2 parameters
  enrollment_cert_id = data.zpa_enrollment_cert.connector_cert.id
  user_codes         = var.test_user_codes # For testing, pass mock tokens
}
