variable "aws_region" {
  type        = string
  description = "AWS region for the test"
  default     = "us-west-2"
}

variable "name_prefix" {
  type        = string
  description = "Name prefix for the bastion test"
  default     = "tbas"
}

variable "resource_tag" {
  type        = string
  description = "Resource tag for the bastion test"
  default     = "test"
}

variable "instance_key" {
  type        = string
  description = "SSH Key for instances"
  default     = "test-key"
}

variable "instance_type" {
  type        = string
  description = "The bastion host EC2 instance type"
  default     = "t3.micro"
}

variable "bastion_nsg_source_prefix" {
  type        = list(string)
  description = "CIDR blocks of trusted networks for bastion host ssh access"
  default     = ["0.0.0.0/0"]
}

variable "iam_role_policy_ssmcore" {
  type        = string
  description = "AWS EC2 Instance predefined IAM Role to access AWS SSM"
  default     = "AmazonSSMManagedInstanceCore"
}
