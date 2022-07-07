# aws variables

variable "aws_region" {
  description = "The AWS region."
  default     = "us-west-2"
}

variable "name_prefix" {
  description = "The name prefix for all your resources"
  default     = "zsdemo"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  default     = "10.1.0.0/16"
}


variable "az_count" {
  description = "Default number of subnets to create based on availability zone"
  type = number
  default     = 2
  validation {
          condition     = (
          (var.az_count >= 1 && var.az_count <= 3)
        )
          error_message = "Input az_count must be set to a single value between 1 and 3. Note* some regions have greater than 3 AZs. Please modify az_count validation in variables.tf if you are utilizing more than 3 AZs in a region that supports it. https://aws.amazon.com/about-aws/global-infrastructure/regions_az/."
      }
}


variable "owner_tag" {
  description = "populate custom owner tag attribute"
  type = string
  default = "zsac-admin"
}

variable "tls_key_algorithm" {
  default   = "RSA"
  type      = string
}

variable "ac_count" {
  description = "Default number of App Connector appliances to create"
  default     = 2
}

variable "acvm_instance_type" {
  description = "App Connector Instance Type"
  default     = "m5a.xlarge"
  validation {
          condition     = ( 
            var.acvm_instance_type == "t3.xlarge"  ||
            var.acvm_instance_type == "m5a.xlarge" 
          )
          error_message = "Input acvm_instance_type must be set to an approved vm instance type."
      }
}

variable "ac_prov_key" {
  description = "zpa app connector provisioning key"
  type = string
}

variable "associate_public_ip_address" {
  default = false
  type = bool
  description = "enable/disable public IP addresses on App Connector instances"
}

variable "byo_iam_instance_profile" {
  default     = false
  type        = bool
  description = "Bring your own IAM Instance Profile for App Connector"
}

variable "byo_iam_instance_profile_id" {
  type = list(string)
  default = null
  description = "IAM Instance Profile ID for App Connector association"
}

variable "byo_security_group" {
  default     = false
  type        = bool
  description = "Bring your own Security Group for App Connector"
}

variable "byo_security_group_id" {
  type = list(string)
  default = null
  description = "Security Group ID for App Connector association"
}

variable "reuse_security_group" {
  description = "Specifies whether the SG module should create 1:1 security groups per instance or 1 security group for all instances"
  default     = "false"
  type        = bool
}

variable "reuse_iam" {
  description = "Specifies whether the SG module should create 1:1 IAM per instance or 1 IAM for all instances"
  default     = "false"
  type        = bool
}