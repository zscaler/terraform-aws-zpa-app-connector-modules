variable "aws_region" {
  type        = string
  description = "AWS region for the test"
  default     = "us-west-2"
}

variable "name_prefix" {
  type        = string
  description = "A prefix to associate to all the App Connector IAM module resources"
  default     = "test-iam"
}

variable "resource_tag" {
  type        = string
  description = "A tag to associate to all the App Connector IAM module resources"
  default     = "test"
}

variable "iam_count" {
  type        = number
  description = "Default number IAM roles/policies/profiles to create"
  default     = 1
}

variable "byo_iam" {
  type        = bool
  description = "Bring your own IAM Instance Profile for App Connector. Setting this variable to true will effectively instruct this module to not create any resources and only reference data resources from values provided in byo_iam_instance_profile_id"
  default     = false
}

variable "byo_iam_instance_profile_id" {
  type        = list(string)
  description = "Existing IAM Instance Profile IDs for App Connector association"
  default     = []
}
