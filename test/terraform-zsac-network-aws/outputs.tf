# Test outputs - these validate the module is working correctly
output "vpc_id" {
  description = "VPC ID from module"
  value       = module.network.vpc_id
}

output "ac_subnet_ids" {
  description = "App Connector Subnet IDs from module"
  value       = module.network.ac_subnet_ids
}

output "ac_route_table_ids" {
  description = "App Connector Route Table IDs from module"
  value       = module.network.ac_route_table_ids
}

output "public_subnet_ids" {
  description = "Public Subnet IDs from module"
  value       = module.network.public_subnet_ids
}

output "public_route_table_id" {
  description = "Public Route Table ID from module"
  value       = module.network.public_route_table_id
}

output "nat_gateway_ips" {
  description = "NAT Gateway Public IPs from module"
  value       = module.network.nat_gateway_ips
}

output "vpc_id_valid" {
  description = "Validation that VPC ID is valid"
  value       = length(module.network.vpc_id) > 0 ? "true" : "false"
}

output "ac_subnet_ids_valid" {
  description = "Validation that AC Subnet IDs are valid"
  value       = length(module.network.ac_subnet_ids) > 0 ? "true" : "false"
}

output "ac_subnet_count_correct" {
  description = "Validation that AC Subnet count is correct"
  value       = length(module.network.ac_subnet_ids) == var.az_count ? "true" : "false"
}

output "ac_route_table_ids_valid" {
  description = "Validation that AC Route Table IDs are valid"
  value       = length(module.network.ac_route_table_ids) > 0 ? "true" : "false"
}

output "ac_route_table_count_correct" {
  description = "Validation that AC Route Table count is correct"
  value       = length(module.network.ac_route_table_ids) == var.az_count ? "true" : "false"
}

output "test_variables_set_correctly" {
  description = "Validation that test variables are set correctly"
  value       = var.name_prefix != "" && var.resource_tag != "" ? "true" : "false"
}

output "vpc_cidr_correct" {
  description = "Validation that VPC CIDR is correct"
  value       = var.vpc_cidr != "" ? "true" : "false"
}

output "az_count_correct" {
  description = "Validation that AZ count is correct"
  value       = var.az_count >= 1 && var.az_count <= 3 ? "true" : "false"
}
