# Variables for EC2 Instance
variable "region" {}
variable "name" {}
variable "global_tags" {}
variable "security_vpc_name" {}
variable "security_vpc_cidr" {}
variable "security_vpc_security_groups" {}
variable "security_vpc_subnets" {}
variable "appconnector-vm" {}
variable "appconnector_version" {}
variable "ssh_key_name" {}
variable "security_vpc_routes_outbound_destin_cidrs" {}
variable "nat_gateway_name" {}
variable "bootstrap_options" {}
variable "iam_instance_profile" {}

# Variables for ZPA App Connector Group
variable "app_connector_group_enabled" {}
variable "app_connector_group_country_code" {}
variable "app_connector_group_latitude" {}
variable "app_connector_group_longitude" {}
variable "app_connector_group_location" {}
variable "app_connector_group_upgrade_day" {}
variable "app_connector_group_upgrade_time_in_secs" {}
variable "app_connector_group_override_version_profile" {}
variable "app_connector_group_version_profile_id" {}
variable "app_connector_group_dns_query_type" {}

# Variables for ZPA Provisioning Key
variable "provisioning_key_association_type" {}
variable "provisioning_key_max_usage" {}

#aws ssm secure parameter
variable "path_to_public_key" {}

# KMS Key Variables
variable "description" {
  description = "Zscaler_KMS_Key"
  default     = "Zscaler_KMS_Key"
  type        = string
}

variable "multi_region" {
  description = "Enable Multi-Region KMS"
  default     = true
  type        = bool
}

# Options available
# SYMMETRIC_DEFAULT, RSA_2048, RSA_3072,
# RSA_4096, ECC_NIST_P256, ECC_NIST_P384,
# ECC_NIST_P521, or ECC_SECG_P256K1
variable "key_spec" {
  default = "SYMMETRIC_DEFAULT"
  type    = string
}

variable "is_enabled" {
  default = true
  type    = bool
}

variable "rotation_enabled" {
  default = false
  type    = bool
}

variable "deletion_window_in_days" {
  default = 30
  type    = number
}

variable "kms_alias" {
  description = "KMS Alias"
  default = "Zscaler_KMS_SSM01"
  type        = string
}