locals {

  testbedconfig = <<TB


VPC:
${module.network.vpc_id}

All AC AZs:
${join("\n", distinct(module.ac_vm.availability_zone))}

All AC Instance IDs:
${join("\n", module.ac_vm.id)}

All AC Private IPs:
${join("\n", module.ac_vm.private_ip)}

All AC Public IPs:
${join("\n", module.ac_vm.public_ip)}

All NAT GW IPs:
${join("\n", module.network.nat_gateway_ips)}

All AC IAM Role ARNs:
${join("\n", module.ac_iam.iam_instance_profile_arn)}

TB
}

output "testbedconfig" {
  description = "AWS Testbed results"
  value       = local.testbedconfig
}

resource "local_file" "testbed" {
  content  = local.testbedconfig
  filename = "./testbed.txt"
}


################################################################################
# Onboarding Outputs
################################################################################
output "onboarding_method" {
  description = "Onboarding method used for this deployment (oauth or provisioning_key)"
  value       = local.use_provisioning_key ? "provisioning_key" : "oauth"
}

output "oauth_user_codes" {
  description = "OAuth2 user codes retrieved from SSM Parameter Store (empty when using the provisioning key flow). Use 'terraform output -json oauth_user_codes | jq -r' to view."
  value       = local.user_codes
  sensitive   = true
}

output "app_connector_group_id" {
  description = "ZPA App Connector Group ID"
  value       = local.use_provisioning_key ? try(module.zpa_app_connector_group_pk[0].app_connector_group_id, "") : try(module.zpa_app_connector_group[0].app_connector_group_id, "")
}

output "ssm_parameter_names" {
  description = "SSM Parameter Store paths where OAuth tokens are stored (managed by Terraform, updated by VMs). Empty when using the provisioning key flow."
  value       = local.ssm_parameter_names
}
