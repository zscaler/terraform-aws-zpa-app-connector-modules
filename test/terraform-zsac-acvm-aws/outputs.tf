# Test outputs - these validate the module is working correctly
output "private_ip" {
  description = "ACVM Private IP Addresses from module"
  value       = module.acvm.private_ip
}

output "availability_zone" {
  description = "ACVM Availability Zones from module"
  value       = module.acvm.availability_zone
}

output "id" {
  description = "ACVM Instance IDs from module"
  value       = module.acvm.id
}

output "public_ip" {
  description = "ACVM Public IP Addresses from module"
  value       = module.acvm.public_ip
}

output "private_ip_valid" {
  description = "Validation that Private IP is valid"
  value       = length(module.acvm.private_ip) > 0 ? "true" : "false"
}

output "availability_zone_valid" {
  description = "Validation that Availability Zone is valid"
  value       = length(module.acvm.availability_zone) > 0 ? "true" : "false"
}

output "instance_id_valid" {
  description = "Validation that Instance ID is valid"
  value       = length(module.acvm.id) > 0 ? "true" : "false"
}

output "test_variables_set_correctly" {
  description = "Validation that test variables are set correctly"
  value       = var.name_prefix != "" && var.resource_tag != "" ? "true" : "false"
}

output "acvm_configuration_valid" {
  description = "Validation that ACVM configuration is valid"
  value       = var.ac_count > 0 ? "true" : "false"
}

output "instance_type_valid" {
  description = "Validation that instance type is valid"
  value       = var.acvm_instance_type != "" ? "true" : "false"
}

output "network_dependencies_valid" {
  description = "Validation that network dependencies are valid"
  value       = length(module.network.ac_subnet_ids) >= 2 && length(module.security_groups.ac_security_group_id) >= 2 && length(module.iam.iam_instance_profile_id) >= 2 ? "true" : "false"
}
