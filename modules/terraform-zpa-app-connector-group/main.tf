################################################################################
# Create ZPA App Connector Group
################################################################################
# Create App Connector Group
resource "zpa_app_connector_group" "app_connector_group" {
  name                     = var.app_connector_group_name
  description              = var.app_connector_group_description
  enabled                  = var.app_connector_group_enabled
  country_code             = var.app_connector_group_country_code
  latitude                 = var.app_connector_group_latitude
  longitude                = var.app_connector_group_longitude
  location                 = var.app_connector_group_location
  upgrade_day              = var.app_connector_group_upgrade_day
  upgrade_time_in_secs     = var.app_connector_group_upgrade_time_in_secs
  override_version_profile = var.app_connector_group_override_version_profile
  version_profile_id       = var.app_connector_group_version_profile_id
  dns_query_type           = var.app_connector_group_dns_query_type
}
