/*
// Create Zscaler Provisioning Key
variable "provisioning_key_name" {
  description = "Name of the provisioning key."
  type        = string
}

variable "provisioning_key_enabled" {
  description = <<-EOF
    Whether the provisioning key is enabled or not. Default: true and Supported values: true, false

  EOF
  default     = true
  type        = bool
}

variable "provisioning_key_association_type" {
  default = "CONNECTOR_GRP"
  type    = string
}

variable "provisioning_key_max_usage" {
  description = <<-EOF
  "The maximum number of instances where this provisioning key can be used for enrolling an App Connector or Service Edge.
  EOF
  type    = number
}

// Create Zscaler App Connector Group
variable "app_connector_group_name" {
  description = "Name of the App Connector Group."
  type    = string
}

variable "app_connector_group_description" {
  description = "Description of the App Connector Group"
  type    = string
}

variable "app_connector_group_enabled" {
  default = true
  type    = bool
}

variable "app_connector_group_country_code" {
  description = "Country Code where the App Connector is located"
  type    = string
}

variable "app_connector_group_latitude" {
  description = <<-EOF
  "Latitude of the App Connector Group." Integer or decimal. With values in the range of -90 to 90

  EOF
  type    = string
}

variable "app_connector_group_longitude" {
  description = <<-EOF
  "Longitude of the App Connector Group." Integer or decimal. With values in the range of -180 to 180

  EOF
  type    = string
}

variable "app_connector_group_location" {
  description = "Location of the App Connector Group."
  type    = string
}

variable "app_connector_group_upgrade_day" {
  description = <<-EOF
  "App Connectors in this group will attempt to update to a newer version of the software during this specified day."
  Default value: SUNDAY. List of valid days (i.e., Sunday, Monday)
  EOF
  type    = string
}

variable "app_connector_group_upgrade_time_in_secs" {
  description = <<-EOF
    "App Connectors in this group will attempt to update to a newer version of the software during this specified time."
     Default value: 66600
     Integer in seconds (i.e., -66600). The integer should be greater than or equal to 0 and less than 86400, in 15 minute intervals
  EOF
  type    = string
}

variable "app_connector_group_override_version_profile" {
  description = <<-EOF
    "Whether the default version profile of the App Connector Group is applied or overridden."

  EOF
  type    = bool
}

variable "app_connector_group_version_profile_id" {
  default = 2
  type    = string
}

variable "app_connector_group_dns_query_type" {
  description = <<-EOF
  "Whether to enable IPv4 or IPv6, or both, for DNS resolution of all applications in the App Connector Group."
  Default: IPV4_IPV6 and Supported values:
    `IPV4_IPV6`
    `IPV4`
    `IPV6`
  EOF
  type    = string
}
*/

variable "app_connector_group_name" { default = null }
variable "app_connector_group_description" { default = null }
variable "app_connector_group_enabled" { default = true }
variable "app_connector_group_country_code" { default = null }
variable "app_connector_group_latitude" { default = null}
variable "app_connector_group_longitude" { default = null }
variable "app_connector_group_location" { default = null }
variable "app_connector_group_upgrade_day" { default = null }
variable "app_connector_group_upgrade_time_in_secs" { default = null }
variable "app_connector_group_override_version_profile" { default = true }
variable "app_connector_group_version_profile_id" { default = null  }
variable "app_connector_group_dns_query_type" { default = null }


variable "provisioning_key_name" { default = null }
variable "provisioning_key_enabled" { default = true }
variable "provisioning_key_association_type" { default = null  }
variable "provisioning_key_max_usage" { default = null }