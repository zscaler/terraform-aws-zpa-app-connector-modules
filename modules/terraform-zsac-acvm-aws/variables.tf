variable "name_prefix" {
  type        = string
  description = "A prefix to associate to all the App Connector module resources"
  default     = null
}

variable "resource_tag" {
  type        = string
  description = "A tag to associate to all the App Connector module resources"
  default     = null
}

variable "global_tags" {
  type        = map(string)
  description = "Populate any custom user defined tags from a map"
  default     = {}
}

variable "ac_subnet_ids" {
  type        = list(string)
  description = "App Connector EC2 Instance subnet ID"
}

variable "instance_key" {
  type        = string
  description = "SSH Key for instances"
}

variable "user_data" {
  type        = string
  description = "App Init data"
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

variable "ac_count" {
  type        = number
  description = "Default number of App Connector appliances to create"
  default     = 1
}

variable "security_group_id" {
  type        = list(string)
  description = "App Connector EC2 Instance management subnet id"
}

variable "iam_instance_profile" {
  type        = list(string)
  description = "IAM instance profile ID assigned to App Connector"
}

variable "associate_public_ip_address" {
  default     = false
  type        = bool
  description = "enable/disable public IP addresses on App Connector instances"
}


 