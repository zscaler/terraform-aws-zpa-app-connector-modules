variable "name_prefix" {
  type        = string
  description = "A prefix to associate to all the App Connector Security Group module resources"
  default     = null
}

variable "resource_tag" {
  type        = string
  description = "A tag to associate to all the App Connector Security Group module resources"
  default     = null
}

variable "global_tags" {
  type        = map(string)
  description = "Populate any custom user defined tags from a map"
  default     = {}
}
