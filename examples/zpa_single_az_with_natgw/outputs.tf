/*
output "public_ips" {
  description = "Map of public IPs created within the module."
  value       = { for k, v in module.app_connector : k => v.public_ips }
}
*/