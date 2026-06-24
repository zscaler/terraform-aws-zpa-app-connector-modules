################################################################################
# Retrieve the "Connector" enrollment certificate used for OAuth2 enrollment.
# This module exclusively onboards App Connectors of type "Connector", so the
# certificate name is intentionally hardcoded and not exposed as a variable.
################################################################################
# data "zpa_enrollment_cert" "connector" {
#   name = "Connector"
# }

################################################################################
# Retrieve the "Default" customer version profile. Only queried when the caller
# overrides the version profile (override_version_profile = true) without
# explicitly pinning a version_profile_id, in which case the module resolves the
# "Default" upgrade track automatically. Supported provider profiles for
# reference: "Default", "Previous Default", "New Release" (and *-el8 variants).
################################################################################
data "zpa_customer_version_profile" "default" {
  count = var.app_connector_group_override_version_profile && var.app_connector_group_version_profile_id == "" ? 1 : 0
  name  = "Default"
}

locals {
  # The ZPA API requires version_profile_id to be "0" whenever the version
  # profile is NOT overridden. When it IS overridden, honor an explicit caller
  # value, otherwise fall back to the resolved "Default" profile id.
  version_profile_id = (
    var.app_connector_group_override_version_profile == false ? "0" :
    var.app_connector_group_version_profile_id != "" ? var.app_connector_group_version_profile_id :
    data.zpa_customer_version_profile.default[0].id
  )
}

################################################################################
# Create ZPA App Connector Group
################################################################################
# Create App Connector Group with OAuth2 support
resource "zpa_app_connector_group" "app_connector_group" {
  name                     = var.app_connector_group_name
  description              = var.app_connector_group_description
  enabled                  = var.app_connector_group_enabled
  country_code             = var.app_connector_group_country_code
  city_country             = var.app_connector_group_city_country
  latitude                 = var.app_connector_group_latitude
  longitude                = var.app_connector_group_longitude
  location                 = var.app_connector_group_location
  upgrade_day              = var.app_connector_group_upgrade_day
  upgrade_time_in_secs     = var.app_connector_group_upgrade_time_in_secs
  override_version_profile = var.app_connector_group_override_version_profile
  version_profile_id       = local.version_profile_id
  dns_query_type           = var.app_connector_group_dns_query_type
  # enrollment_cert_id       = data.zpa_enrollment_cert.connector.id
  user_codes = var.user_codes
}
