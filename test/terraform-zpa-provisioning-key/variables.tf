################################################################################
# Variables for ZPA Provisioning Key Test
################################################################################

variable "enrollment_cert" {
  type        = string
  description = "Enrollment certificate name"
  default     = "Connector"
}

variable "provisioning_key_name" {
  type        = string
  description = "Name of the provisioning key"
}

variable "provisioning_key_enabled" {
  type        = bool
  description = "Whether the provisioning key is enabled"
  default     = true
}

variable "provisioning_key_association_type" {
  type        = string
  description = "Association type for the provisioning key"
  default     = "CONNECTOR_GRP"
}

variable "provisioning_key_max_usage" {
  type        = string
  description = "Maximum usage for the provisioning key"
  default     = "10"
}

variable "app_connector_group_id" {
  type        = string
  description = "App Connector Group ID"
}

variable "byo_provisioning_key" {
  type        = bool
  description = "Whether to use an existing provisioning key"
  default     = false
}

variable "byo_provisioning_key_name" {
  type        = string
  description = "Name of existing provisioning key to use"
  default     = ""
}
