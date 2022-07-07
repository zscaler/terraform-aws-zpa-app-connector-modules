# aws variables

variable "aws_region" {
  description = "The AWS region."
  default     = "us-west-2"
}

variable "name_prefix" {
  description = "The name prefix for all your resources"
  default     = "zsdemo"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  default     = "10.1.0.0/16"
}

variable "az_count" {
  description = "Default number of subnets to create based on availability zone"
  type = number
  default     = 2
  validation {
          condition     = (
          (var.az_count >= 1 && var.az_count <= 3)
        )
          error_message = "Input az_count must be set to a single value between 1 and 3. Note* some regions have greater than 3 AZs. Please modify az_count validation in variables.tf if you are utilizing more than 3 AZs in a region that supports it. https://aws.amazon.com/about-aws/global-infrastructure/regions_az/."
      }
}

variable "owner_tag" {
  description = "populate custom owner tag attribute"
  type = string
  default = "zsac-admin"
}

variable "tls_key_algorithm" {
  default   = "RSA"
  type      = string
}

variable "ac_count" {
  description = "Default number of App Connector appliances to create"
  default     = 2
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

variable "ac_prov_key" {
  description = "zpa app connector provisioning key"
  type = string
}

variable "associate_public_ip_address" {
  default = false
  type = bool
  description = "enable/disable public IP addresses on App Connector instances"
}

variable "health_check_grace_period" {
  description = "The amount of time until EC2 Auto Scaling performs the first health check on new instances after they are put into service."
  type        = number
  default     = 300
}

variable "min_size" {
  description = "mininum number of cloud connectors to maintain in Autoscaling group"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "maxinum number of cloud connectors to maintain in Autoscaling group"
  type        = number
  default     = 4
}

variable "target_value" {
  description = "target value number for autoscaling policy CPU utilization target tracking"
  type        = number
  default     = 50
}

variable "warm_pool_state" {
  description = "Sets the instance state to transition to after the lifecycle hooks finish. Valid values are: Stopped (default), Running or Hibernated. Ignored when 'warm_pool_enabled' is false"
  default     = null
}

variable "warm_pool_min_size" {
  description = "Specifies the minimum number of instances to maintain in the warm pool. This helps you to ensure that there is always a certain number of warmed instances available to handle traffic spikes. Ignored when 'warm_pool_enabled' is false"
  type        = number
  default     = null
}

variable "warm_pool_max_group_prepared_capacity" {
  description = "Specifies the total maximum number of instances that are allowed to be in the warm pool or in any state except Terminated for the Auto Scaling group. Ignored when 'warm_pool_enabled' is false"
  default     = null
}

variable "warm_pool_enabled" {
  description = "If set to true, add a warm pool to the specified Auto Scaling group. See [warm_pool](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group#warm_pool)."
  default     = "false"
  type        = bool
}

variable "reuse_on_scale_in" {
  description = "Specifies whether instances in the Auto Scaling group can be returned to the warm pool on scale in."
  default     = "false"
  type        = bool
}

variable "launch_template_version" {
  type        = string
  description = "Launch template version. Can be version number, `$Latest` or `$Default`"
  default     = "$Latest"
}

variable "target_tracking_metric" {
  default = "ASGAverageCPUUtilization"
   validation {
          condition = ( 
            var.target_tracking_metric == "ASGAverageCPUUtilization"  ||
            var.target_tracking_metric == "ASGAverageNetworkIn" ||
            var.target_tracking_metric == "ASGAverageNetworkOut"
          )
          error_message = "Input target_tracking_metric must be set to an approved predefined metric."
      }
}

variable "byo_iam_instance_profile" {
  default     = false
  type        = bool
  description = "Bring your own IAM Instance Profile for App Connector"
}

variable "byo_iam_instance_profile_id" {
  type = list(string)
  default = null
  description = "IAM Instance Profile ID for App Connector association"
}

variable "byo_security_group" {
  default     = false
  type        = bool
  description = "Bring your own Security Group for App Connector"
}

variable "byo_security_group_id" {
  type = list(string)
  default = null
  description = "Security Group ID for App Connector association"
}