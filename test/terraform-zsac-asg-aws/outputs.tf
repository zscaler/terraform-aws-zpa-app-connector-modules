# Test outputs - these validate the module is working correctly
output "availability_zone" {
  description = "ASG Availability Zones from module"
  value       = module.asg.availability_zone
}

output "availability_zone_valid" {
  description = "Validation that Availability Zone is valid"
  value       = length(module.asg.availability_zone) > 0 ? "true" : "false"
}

output "test_variables_set_correctly" {
  description = "Validation that test variables are set correctly"
  value       = var.name_prefix != "" && var.resource_tag != "" ? "true" : "false"
}

output "asg_configuration_valid" {
  description = "Validation that ASG configuration is valid"
  value       = var.min_size <= var.max_size ? "true" : "false"
}

output "instance_type_valid" {
  description = "Validation that instance type is valid"
  value       = var.acvm_instance_type != "" ? "true" : "false"
}

output "network_dependencies_valid" {
  description = "Validation that network dependencies are valid"
  value       = length(module.network.ac_subnet_ids) >= 2 && length(module.security_groups.ac_security_group_id) >= 2 && length(module.iam.iam_instance_profile_id) >= 2 ? "true" : "false"
}
