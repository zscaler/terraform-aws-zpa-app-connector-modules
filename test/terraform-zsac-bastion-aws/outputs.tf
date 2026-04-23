# Test outputs - these validate the module is working correctly
output "public_ip" {
  description = "Bastion Host Public IP from module"
  value       = module.bastion.public_ip
}

output "public_dns" {
  description = "Bastion Host Public DNS from module"
  value       = module.bastion.public_dns
}

output "public_ip_valid" {
  description = "Validation that Public IP is valid"
  value       = module.bastion.public_ip != null && module.bastion.public_ip != "" ? "true" : "false"
}

output "public_dns_valid" {
  description = "Validation that Public DNS is valid"
  value       = module.bastion.public_dns != null && module.bastion.public_dns != "" ? "true" : "false"
}

output "test_variables_set_correctly" {
  description = "Validation that test variables are set correctly"
  value       = var.name_prefix != "" && var.resource_tag != "" ? "true" : "false"
}

output "instance_type_valid" {
  description = "Validation that instance type is valid"
  value       = var.instance_type != "" ? "true" : "false"
}

output "network_dependencies_valid" {
  description = "Validation that network dependencies are valid"
  value       = module.network.vpc_id != "" && length(module.network.public_subnet_ids) > 0 ? "true" : "false"
}
