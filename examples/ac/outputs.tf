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
# OAuth2 Token Outputs
################################################################################
output "oauth_user_codes" {
  description = "OAuth2 user codes retrieved from SSM Parameter Store. Use 'terraform output -json oauth_user_codes | jq -r' to view."
  value       = local.user_codes
  sensitive   = true
}

output "app_connector_group_id" {
  description = "ZPA App Connector Group ID"
  value       = module.zpa_app_connector_group.app_connector_group_id
}

output "enrollment_cert_id" {
  description = "ZPA Enrollment Certificate ID used for App Connector enrollment"
  value       = data.zpa_enrollment_cert.connector_cert.id
}

output "ssm_parameter_names" {
  description = "SSM Parameter Store paths where OAuth tokens are stored (managed by Terraform, updated by VMs)"
  value       = local.ssm_parameter_names
}
