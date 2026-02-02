locals {

  testbedconfig = <<TB

1) Copy the SSH key to the bastion host
scp -i ${var.name_prefix}-key-${random_string.suffix.result}.pem ${var.name_prefix}-key-${random_string.suffix.result}.pem ec2-user@${module.bastion.public_dns}:/home/ec2-user/.

2) SSH to the bastion host
ssh -i ${var.name_prefix}-key-${random_string.suffix.result}.pem ec2-user@${module.bastion.public_dns}

3) SSH to the App Connector
ssh -i ${var.name_prefix}-key-${random_string.suffix.result}.pem admin@${module.ac_vm.private_ip[0]} -o "proxycommand ssh -W %h:%p -i ${var.name_prefix}-key-${random_string.suffix.result}.pem ec2-user@${module.bastion.public_dns}"

All AC Private IPs. Replace private IP below with admin@"ip address" in ssh example command above. ec2-user@"ip address" for AL2 AMI deployments
${join("\n", module.ac_vm.private_ip)}

VPC:
${module.network.vpc_id}

All AC AZs:
${join("\n", distinct(module.ac_vm.availability_zone))}

All AC Instance IDs:
${join("\n", module.ac_vm.id)}

All AC Public IPs:
${join("\n", module.ac_vm.public_ip)}

All AC IAM Role ARNs:
${join("\n", module.ac_iam.iam_instance_profile_arn)}

All NAT GW IPs:
${join("\n", module.network.nat_gateway_ips)}

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
