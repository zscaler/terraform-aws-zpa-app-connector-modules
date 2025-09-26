################################################################################
# Variables for ZPA App Connector Group Test
################################################################################

variable "app_connector_group_name" {
  type        = string
  description = "Name of the App Connector Group"
}

variable "app_connector_group_description" {
  type        = string
  description = "Description of the App Connector Group"
  default     = "Test App Connector Group"
}

variable "app_connector_group_enabled" {
  type        = bool
  description = "Whether the App Connector Group is enabled"
  default     = true
}

variable "app_connector_group_country_code" {
  type        = string
  description = "Country code for the App Connector Group"
  default     = "US"
}

variable "app_connector_group_latitude" {
  type        = string
  description = "Latitude for the App Connector Group location"
}

variable "app_connector_group_longitude" {
  type        = string
  description = "Longitude for the App Connector Group location"
}

variable "app_connector_group_location" {
  type        = string
  description = "Location description for the App Connector Group"
}

variable "app_connector_group_upgrade_day" {
  type        = string
  description = "Day of the week for upgrades"
  default     = "SUNDAY"
}

variable "app_connector_group_upgrade_time_in_secs" {
  type        = string
  description = "Time in seconds for upgrades"
  default     = "66600"
}

variable "app_connector_group_override_version_profile" {
  type        = bool
  description = "Whether to override the version profile"
  default     = true
}

variable "app_connector_group_version_profile_id" {
  type        = string
  description = "Version profile ID"
  default     = "0"
}

variable "app_connector_group_dns_query_type" {
  type        = string
  description = "DNS query type"
  default     = "IPV4_IPV6"
}
