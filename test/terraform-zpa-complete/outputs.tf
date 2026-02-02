# Test outputs - these validate the modules are working correctly
output "app_connector_group_id" {
  description = "ZPA App Connector Group ID from module"
  value       = module.app_connector_group.app_connector_group_id
}

output "app_connector_group_oauth2_id" {
  description = "ZPA App Connector Group ID from OAuth2 module"
  value       = module.app_connector_group_oauth2.app_connector_group_id
}

output "enrollment_cert_id" {
  description = "ZPA Enrollment Certificate ID"
  value       = data.zpa_enrollment_cert.connector_cert.id
}
