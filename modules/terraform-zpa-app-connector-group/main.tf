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
  version_profile_id       = var.app_connector_group_version_profile_id
  dns_query_type           = var.app_connector_group_dns_query_type

  # OAuth2 enrollment. When user_codes is populated the ZPA provider implicitly
  # verifies the codes against the OAuth2 endpoint and enrolls the connectors.
  # The enrollment certificate is auto-resolved by the provider (it looks up the
  # "Connector" certificate by name), so enrollment_cert_id is intentionally not
  # set here. Leave user_codes empty when onboarding via provisioning key.
  user_codes = var.user_codes

  lifecycle {
    # The ZPA API derives city_country from the supplied latitude/longitude and
    # returns it on read, but the provider schema marks the field Optional
    # (not Computed). When city_country is left empty in config, Terraform reads
    # the API-derived value into state and then perpetually plans to reset it to
    # "", making the apply non-idempotent. Ignoring post-create changes to this
    # API-managed field keeps plans clean.
    ignore_changes = [city_country]
  }
}
