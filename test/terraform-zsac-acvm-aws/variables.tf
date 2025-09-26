variable "name_prefix" {
  type        = string
  description = "A prefix to associate to all the App Connector module resources"
  default     = "tacvm"
}

variable "resource_tag" {
  type        = string
  description = "A tag to associate to all the App Connector module resources"
  default     = "test"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-west-2"
}

variable "user_data" {
  type        = string
  description = "App Init data"
  default     = "#!/bin/bash\necho 'App Connector VM initialized'"
}

variable "acvm_instance_type" {
  type        = string
  description = "App Connector Instance Type"
  default     = "t3.medium"
}

variable "ami_id" {
  type        = list(string)
  description = "AMI ID(s) to be used for deploying App Connector appliances"
  default     = [""]
}

variable "ac_count" {
  type        = number
  description = "Number of App Connector appliances to create"
  default     = 2
}

variable "associate_public_ip_address" {
  type        = bool
  description = "Enable/disable public IP addresses on App Connector instances"
  default     = false
}

variable "imdsv2_enabled" {
  type        = bool
  description = "True/false whether to force IMDSv2 only for instance bring up"
  default     = true
}
