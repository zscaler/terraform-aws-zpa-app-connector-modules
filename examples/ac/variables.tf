variable "aws_region" {
  type        = string
  description = "The AWS region."
  default     = "us-west-2"
}

variable "name_prefix" {
  type        = string
  description = "The name prefix for all your resources"
  default     = "zsdemo"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC IP CIDR Range. All subnet resources that might get created (public / app connector) are derived from this /16 CIDR. If you require creating a VPC smaller than /16, you may need to explicitly define all other subnets via public_subnets and ac_subnets variables"
  default     = "10.1.0.0/16"
}

variable "public_subnets" {
  type        = list(string)
  description = "Public/NAT GW Subnets to create in VPC. This is only required if you want to override the default subnets that this code creates via vpc_cidr variable."
  default     = null
}

variable "ac_subnets" {
  type        = list(string)
  description = "App Connector Subnets to create in VPC. This is only required if you want to override the default subnets that this code creates via vpc_cidr variable."
  default     = null
}

variable "az_count" {
  type        = number
  description = "Default number of subnets to create based on availability zone input"
  default     = 2
  validation {
    condition = (
      (var.az_count >= 1 && var.az_count <= 3)
    )
    error_message = "Input az_count must be set to a single value between 1 and 3. Note* some regions have greater than 3 AZs. Please modify az_count validation in variables.tf if you are utilizing more than 3 AZs in a region that supports it. https://aws.amazon.com/about-aws/global-infrastructure/regions_az/."
  }
}

variable "owner_tag" {
  type        = string
  description = "populate custom owner tag attribute"
  default     = "zsac-admin"
}

variable "tls_key_algorithm" {
  type        = string
  description = "algorithm for tls_private_key resource"
  default     = "RSA"
}

variable "bastion_nsg_source_prefix" {
  type        = list(string)
  description = "CIDR blocks of trusted networks for bastion host ssh access"
  default     = ["0.0.0.0/0"]
}

variable "ac_count" {
  type        = number
  description = "Default number of App Connector appliances to create"
  default     = 1
}

variable "acvm_instance_type" {
  description = "App Connector Instance Type"
  default     = "m5a.xlarge"
  validation {
    condition = (
      var.acvm_instance_type == "t3.xlarge" ||
      var.acvm_instance_type == "m5a.xlarge"
    )
    error_message = "Input acvm_instance_type must be set to an approved vm instance type."
  }
}

variable "ac_prov_key" {
  type        = string
  description = "ZPA App Connector provisioning key"
}

variable "reuse_security_group" {
  type        = bool
  description = "Specifies whether the SG module should create 1:1 security groups per instance or 1 security group for all instances"
  default     = false
}

variable "reuse_iam" {
  type        = bool
  description = "Specifies whether the SG module should create 1:1 IAM per instance or 1 IAM for all instances"
  default     = false
}

variable "associate_public_ip_address" {
  default     = false
  type        = bool
  description = "enable/disable public IP addresses on App Connector instances. Setting this to true will result in the following: Dynamic Public IP address on the App Connector VM Instance will be enabled; no EIP or NAT Gateway resources will be created; and the App Connector Route Table default route next-hop will be set as the IGW"
}


# BYO (Bring-your-own) variables list
variable "byo_vpc" {
  type        = bool
  description = "Bring your own AWS VPC for App Connector"
  default     = false
}

variable "byo_vpc_id" {
  type        = string
  description = "User provided existing AWS VPC ID"
  default     = null
}

variable "byo_subnets" {
  type        = bool
  description = "Bring your own AWS Subnets for App Connector"
  default     = false
}

variable "byo_subnet_ids" {
  type        = list(string)
  description = "User provided existing AWS Subnet IDs"
  default     = null
}

variable "byo_igw" {
  type        = bool
  description = "Bring your own AWS VPC for App Connector"
  default     = false
}

variable "byo_igw_id" {
  type        = string
  description = "User provided existing AWS Internet Gateway ID"
  default     = null
}

variable "byo_ngw" {
  type        = bool
  description = "Bring your own AWS NAT Gateway(s) App Connector"
  default     = false
}

variable "byo_ngw_ids" {
  type        = list(string)
  description = "User provided existing AWS NAT Gateway IDs"
  default     = null
}

variable "byo_iam" {
  type        = bool
  description = "Bring your own IAM Instance Profile for App Connector"
  default     = false
}

variable "byo_iam_instance_profile_id" {
  type        = list(string)
  description = "IAM Instance Profile ID for App Connector association"
  default     = null
}

variable "byo_security_group" {
  type        = bool
  description = "Bring your own Security Group for App Connector"
  default     = false
}

variable "byo_security_group_id" {
  type        = list(string)
  description = "Management Security Group ID for App Connector association"
  default     = null
}