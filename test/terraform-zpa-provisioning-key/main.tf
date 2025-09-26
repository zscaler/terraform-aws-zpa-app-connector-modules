################################################################################
# ZPA Provider Configuration
################################################################################
terraform {
  required_providers {
    zpa = {
      source = "zscaler/zpa"
    }
  }
  required_version = ">= 0.13.7, < 2.0.0"
}

# Configure the ZPA Provider
provider "zpa" {
  # ZPA provider configuration will be set via environment variables:
  # ZPA_CLIENT_ID, ZPA_CLIENT_SECRET, ZPA_CUSTOMER_ID, ZPA_CLOUD
}

################################################################################
# Test Module - Provisioning Key
################################################################################
module "zpa_provisioning_key" {
  source = "../../modules/terraform-zpa-provisioning-key"

  # Required parameters
  enrollment_cert        = var.enrollment_cert
  provisioning_key_name  = var.provisioning_key_name
  app_connector_group_id = var.app_connector_group_id

  # Optional parameters
  provisioning_key_enabled          = var.provisioning_key_enabled
  provisioning_key_association_type = var.provisioning_key_association_type
  provisioning_key_max_usage        = var.provisioning_key_max_usage
  byo_provisioning_key              = var.byo_provisioning_key
  byo_provisioning_key_name         = var.byo_provisioning_key_name
}

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
