# App Connector Group variables
variable "app_connector_group_name" {
  type        = string
  description = "Name of the App Connector Group"
}

variable "app_connector_group_description" {
  type        = string
  description = "Description of the App Connector Group"
}

variable "app_connector_group_enabled" {
  type        = bool
  description = "Whether the App Connector Group is enabled"
}

variable "app_connector_group_country_code" {
  type        = string
  description = "Country code for the App Connector Group"
}

variable "app_connector_group_latitude" {
  type        = string
  description = "Latitude of the App Connector Group"
}

variable "app_connector_group_longitude" {
  type        = string
  description = "Longitude of the App Connector Group"
}

variable "app_connector_group_location" {
  type        = string
  description = "Location of the App Connector Group"
}

variable "app_connector_group_upgrade_day" {
  type        = string
  description = "Upgrade day for the App Connector Group"
}

variable "app_connector_group_upgrade_time_in_secs" {
  type        = string
  description = "Upgrade time in seconds for the App Connector Group"
}

variable "app_connector_group_override_version_profile" {
  type        = bool
  description = "Whether to override the version profile"
}

variable "app_connector_group_version_profile_id" {
  type        = string
  description = "Version profile ID for the App Connector Group"
}

variable "app_connector_group_dns_query_type" {
  type        = string
  description = "DNS query type for the App Connector Group"
}

# OAuth2 variables
variable "enrollment_cert" {
  type        = string
  description = "Enrollment certificate name for OAuth2"
  default     = "Connector"
}

variable "test_user_codes" {
  type        = list(string)
  description = "Test OAuth2 user codes for testing purposes"
  default     = []
}
