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

# Provisioning Key variables
variable "provisioning_key_name" {
  type        = string
  description = "Name of the Provisioning Key"
}

variable "provisioning_key_enabled" {
  type        = bool
  description = "Whether the Provisioning Key is enabled"
}

variable "provisioning_key_association_type" {
  type        = string
  description = "Association type for the Provisioning Key"
}

variable "provisioning_key_max_usage" {
  type        = string
  description = "Maximum usage for the Provisioning Key"
}

variable "byo_provisioning_key" {
  type        = bool
  description = "Whether to bring your own provisioning key"
}

variable "byo_provisioning_key_name" {
  type        = string
  description = "Name of the BYO provisioning key"
}

variable "enrollment_cert" {
  type        = string
  description = "Enrollment certificate name"
}
