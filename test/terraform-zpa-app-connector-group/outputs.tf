# Test outputs - these validate the module is working correctly
output "app_connector_group_id" {
  description = "ZPA App Connector Group ID from module"
  value       = module.zpa_app_connector_group.app_connector_group_id
}

output "app_connector_group_id_valid" {
  description = "Validation that App Connector Group ID is valid"
  value       = length(module.zpa_app_connector_group.app_connector_group_id) > 0 ? "true" : "false"
}

output "test_variables_set_correctly" {
  description = "Validation that test variables are set correctly"
  value       = var.app_connector_group_name != "" && var.app_connector_group_location != "" ? "true" : "false"
}
