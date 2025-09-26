variable "aws_region" {
  type        = string
  description = "AWS region for the test"
  default     = "us-west-2"
}

variable "name_prefix" {
  type        = string
  description = "A prefix to associate to all the network module resources"
  default     = "test-network"
}

variable "resource_tag" {
  type        = string
  description = "A tag to associate to all the network module resources"
  default     = "test"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC IP CIDR Range. All subnet resources that might get created (public / App connector) are derived from this /16 CIDR"
  default     = "10.1.0.0/16"
}

variable "az_count" {
  type        = number
  description = "Default number of subnets to create based on availability zone input"
  default     = 2
}

variable "associate_public_ip_address" {
  type        = bool
  description = "Enable/disable public IP addresses on App Connector instances"
  default     = false
}

variable "byo_vpc" {
  type        = bool
  description = "Bring your own VPC for App Connector. Setting this variable to true will effectively instruct this module to not create any VPC resources and only reference data resources from values provided in byo_vpc_id"
  default     = false
}

variable "byo_vpc_id" {
  type        = string
  description = "User provided existing VPC ID for bringing in your own VPC. This value becomes the default VPC ID for the module when byo_vpc is set to true"
  default     = ""
}

variable "byo_igw" {
  type        = bool
  description = "Bring your own Internet Gateway for App Connector. Setting this variable to true will effectively instruct this module to not create any Internet Gateway resources and only reference data resources from values provided in byo_igw_id"
  default     = false
}

variable "byo_igw_id" {
  type        = string
  description = "User provided existing Internet Gateway ID for bringing in your own Internet Gateway. This value becomes the default Internet Gateway ID for the module when byo_igw is set to true"
  default     = ""
}

variable "byo_ngw" {
  type        = bool
  description = "Bring your own NAT Gateway for App Connector. Setting this variable to true will effectively instruct this module to not create any NAT Gateway resources and only reference data resources from values provided in byo_ngw_ids"
  default     = false
}

variable "byo_ngw_ids" {
  type        = list(string)
  description = "User provided existing NAT Gateway IDs for bringing in your own NAT Gateway(s). This value becomes the default NAT Gateway ID(s) for the module when byo_ngw is set to true"
  default     = []
}

variable "byo_subnets" {
  type        = bool
  description = "Bring your own App Connector Subnets. Setting this variable to true will effectively instruct this module to not create any App Connector subnet resources and only reference data resources from values provided in byo_subnet_ids"
  default     = false
}

variable "byo_subnet_ids" {
  type        = list(string)
  description = "User provided existing App Connector Subnet IDs for bringing in your own App Connector Subnets. This value becomes the default App Connector Subnet ID(s) for the module when byo_subnets is set to true"
  default     = []
}

variable "public_subnets" {
  type        = list(string)
  description = "Public/NAT GW Subnets to create in VPC. This is only required if you want to override the default subnets that this code creates via vpc_cidr variable"
  default     = null
}

variable "ac_subnets" {
  type        = list(string)
  description = "App Connector Subnets to create in VPC. This is only required if you want to override the default subnets that this code creates via vpc_cidr variable"
  default     = null
}
