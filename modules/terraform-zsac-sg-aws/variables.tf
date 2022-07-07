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

variable "global_tags" {
  type        = map
  description = "populate custom user provided tags"
}

variable "sg_count" {
  description = "Default number of security groups to create"
  default     = 1
}