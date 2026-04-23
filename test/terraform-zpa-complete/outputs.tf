# Test outputs - these validate the modules are working correctly
output "app_connector_group_id" {
  description = "ZPA App Connector Group ID from module"
  value       = module.app_connector_group.app_connector_group_id
}

output "provisioning_key" {
  description = "ZPA Provisioning Key from module"
  value       = module.provisioning_key.provisioning_key
  sensitive   = true
}
