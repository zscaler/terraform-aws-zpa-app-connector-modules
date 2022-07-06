variable "name_prefix" {
  description = "A prefix to associate to all the Cloud Connector module resources"
  default     = "zscaler-cc"
}

variable "resource_tag" {
  description = "A tag to associate to all the Cloud Connector module resources"
  default     = "cloud-connector"
}

variable "vpc" {
  description = "Cloud Connector VPC"
}

variable "subnet_id" {
  type        = list(string)
  description = "App Connector EC2 Instance subnet id"
}

variable "instance_key" {
  description = "Cloud Connector Instance Key"
}

variable "user_data" {
  description = "Cloud Init data"
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

variable "global_tags" {
  description = "populate custom user provided tags"
}

variable "ac_count" {
  description = "Default number of App Connector appliances to create"
  default = 1
}

variable "iam_instance_profile" {
  type        = list(string)
  description = "IAM instance profile ID assigned to App Connector"
  default     = null
}

variable "security_group_id" {
  type        = list(string)
  description = "Security Group ID assigned to App Connector"
  default     = null
}

variable "associate_public_ip_address" {
  default = false
  type = bool
  description = "enable/disalbe public IP addresses on App Connector instances"
}


