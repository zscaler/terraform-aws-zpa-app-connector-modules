variable "aws_region" {
  type        = string
  description = "AWS region for the test"
  default     = "us-west-2"
}

variable "name_prefix" {
  type        = string
  description = "Name prefix for the ASG test"
  default     = "tasg"
}

variable "resource_tag" {
  type        = string
  description = "Resource tag for the ASG test"
  default     = "test"
}

variable "instance_key" {
  type        = string
  description = "SSH Key for instances"
  default     = "test-key"
}

variable "user_data" {
  type        = string
  description = "User data script for App Connector initialization"
  default     = "#!/bin/bash\necho 'Test user data'"
}

variable "acvm_instance_type" {
  type        = string
  description = "App Connector Instance Type"
  default     = "t3.medium"
}

variable "ami_id" {
  type        = list(string)
  description = "AMI ID(s) for App Connector instances"
  default     = [""]
}

variable "min_size" {
  type        = number
  description = "Minimum number of App Connectors in ASG"
  default     = 1
}

variable "max_size" {
  type        = number
  description = "Maximum number of App Connectors in ASG"
  default     = 2
}

variable "health_check_grace_period" {
  type        = number
  description = "Health check grace period in seconds"
  default     = 300
}

variable "ebs_block_device_name" {
  type        = string
  description = "EBS block device name"
  default     = "/dev/xvda"
}

variable "ebs_encrypted" {
  type        = bool
  description = "Whether to encrypt the EBS volume"
  default     = true
}

variable "ebs_kms_key_arn" {
  type        = string
  description = "KMS key ARN for EBS volume encryption"
  default     = null
}

variable "ebs_volume_type" {
  type        = string
  description = "EBS volume type"
  default     = "gp3"
}

variable "target_tracking_metric" {
  type        = string
  description = "ASG target tracking metric"
  default     = "ASGAverageCPUUtilization"
}

variable "target_cpu_util_value" {
  type        = number
  description = "Target CPU utilization percentage"
  default     = 50
}

variable "imdsv2_enabled" {
  type        = bool
  description = "Enable IMDSv2"
  default     = true
}

variable "metadata_options" {
  type        = map(string)
  description = "Metadata options for the instance"
  default = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }
}

variable "associate_public_ip_address" {
  type        = bool
  description = "Associate public IP address"
  default     = false
}

variable "warm_pool_enabled" {
  type        = bool
  description = "Enable warm pool"
  default     = false
}

variable "warm_pool_state" {
  type        = string
  description = "Warm pool state"
  default     = null
}

variable "warm_pool_min_size" {
  type        = number
  description = "Warm pool minimum size"
  default     = null
}

variable "warm_pool_max_group_prepared_capacity" {
  type        = number
  description = "Warm pool max group prepared capacity"
  default     = null
}

variable "reuse_on_scale_in" {
  type        = bool
  description = "Reuse instances on scale in"
  default     = false
}

variable "launch_template_version" {
  type        = string
  description = "Launch template version"
  default     = "$Latest"
}
