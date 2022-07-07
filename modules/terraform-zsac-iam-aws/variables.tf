variable "name_prefix" {
  description = "A prefix to associate to all the Cloud Connector module resources"
  default     = "zscaler-cc"
}

variable "resource_tag" {
  description = "A tag to associate to all the Cloud Connector module resources"
  default     = "cloud-connector"
}

variable "global_tags" {
  type        = map
  description = "populate custom user provided tags"
}

variable "iam_role_policy_smrw" {
  description = "Cloud Connector EC2 Instance IAM Role"
  default     = "SecretsManagerReadWrite"
}

variable "iam_role_policy_ssmcore" {
  description = "Cloud Connector EC2 Instance IAM Role"
  default     = "AmazonSSMManagedInstanceCore"
}

variable "iam_count" {
  description = "Default number IAM roles/policies/profiles to create"
  default = 1
}