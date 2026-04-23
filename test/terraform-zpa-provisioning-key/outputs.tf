# Test outputs - these validate the module is working correctly
output "provisioning_key" {
  description = "ZPA Provisioning Key from module"
  value       = module.zpa_provisioning_key.provisioning_key
  sensitive   = true
}

output "provisioning_key_valid" {
  description = "Validation that Provisioning Key is valid"
  value       = length(module.zpa_provisioning_key.provisioning_key) > 0 ? "true" : "false"
}

output "test_variables_set_correctly" {
  description = "Validation that test variables are set correctly"
  value       = var.provisioning_key_name != "" && var.app_connector_group_id != "" ? "true" : "false"
}
