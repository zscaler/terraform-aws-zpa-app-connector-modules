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
  description = "populate custom user provided tags"
  type        = map
}

variable "iam_instance_profile" {
  description = "IAM instance profile ID assigned to App Connector"
  type        = list(string)
  default     = null
}

variable "security_group_id" {
  description = "Security Group ID assigned to App Connector"
  type        = list(string)
  default     = null
}

variable "associate_public_ip_address" {
  description = "enable/disalbe public IP addresses on App Connector instances"
  type        = bool
  default     = false
}

variable "min_size" {
  description = "mininum number of App connectors to maintain in Autoscaling group"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "maxinum number of App connectors to maintain in Autoscaling group"
  type        = number
  default     = 4
}

variable "target_value" {
  description = "target value number for autoscaling policy CPU utilization target tracking"
  type        = number
  default     = 50
}

variable "ac_subnet_ids" {
  description = "App Connector subnet IDs list"
  type        = list(string)
}

variable "health_check_grace_period" {
  description = "The amount of time until EC2 Auto Scaling performs the first health check on new instances after they are put into service."
  type        = number
  default     = 300
}

variable "warm_pool_enabled" {
  description = "If set to true, add a warm pool to the specified Auto Scaling group. See [warm_pool](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group#warm_pool)."
  default     = "false"
  type        = bool
}

variable "warm_pool_state" {
  description = "Sets the instance state to transition to after the lifecycle hooks finish. Valid values are: Stopped (default), Running or Hibernated. Ignored when 'warm_pool_enabled' is false"
  default     = null
  validation {
          condition = ( 
            var.warm_pool_state == "Stopped"  ||
            var.warm_pool_state == "Running" ||
            var.warm_pool_state == "Hibernated" ||
            var.warm_pool_state == null
          )
          error_message = "Input warm_pool_state must be set to an approved value."
      }
}

variable "warm_pool_min_size" {
  description = "Specifies the minimum number of instances to maintain in the warm pool. This helps you to ensure that there is always a certain number of warmed instances available to handle traffic spikes. Ignored when 'warm_pool_enabled' is false"
  type        = number
  default     = null
}

variable "warm_pool_max_group_prepared_capacity" {
  description = "Specifies the total maximum number of instances that are allowed to be in the warm pool or in any state except Terminated for the Auto Scaling group. Ignored when 'warm_pool_enabled' is false"
  type        = number
  default     = null
}

variable "reuse_on_scale_in" {
  description = "Specifies whether instances in the Auto Scaling group can be returned to the warm pool on scale in."
  default     = "false"
  type        = bool
}

variable "launch_template_version" {
  description = "Launch template version. Can be version number, `$Latest` or `$Default`"
  type        = string
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
