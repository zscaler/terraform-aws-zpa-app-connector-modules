variable "name_prefix" {
  description = "A prefix to associate to all the App Connector module resources"
  default     = "zscaler-ac"
}

variable "resource_tag" {
  description = "A tag to associate to all the App Connector module resources"
  default     = "app-connector"
}

variable "vpc" {
  description = "App Connector VPC"
}

variable "ac_subnet_ids" {
  type        = list(string)
  description = "App Connector EC2 Instance subnet ids"
}

variable "instance_key" {
  description = "App Connector Instance Key"
}

variable "ac_prov_key" {
  description = "zpa app connector provisioning key"
  type = string
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
  type        = map
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


