variable "name_prefix" {
  description = "A prefix to associate to all the Cloud Connector module resources"
  default     = "zscaler-cc"
}

variable "resource_tag" {
  description = "A tag to associate to all the Cloud Connector module resources"
  default     = "cloud-connector"
}

variable "iam_role_policy_smrw" {
  description = "Cloud Connector EC2 Instance IAM Role"
  default     = "SecretsManagerReadWrite"
}

variable "iam_role_policy_ssmcore" {
  description = "Cloud Connector EC2 Instance IAM Role"
  default     = "AmazonSSMManagedInstanceCore"
}

variable "ac_count" {
  description = "Default number of App Connector appliances to create"
  default = 1
}