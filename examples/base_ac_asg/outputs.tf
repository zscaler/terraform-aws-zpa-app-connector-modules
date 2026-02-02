locals {

  testbedconfig = <<TB

1) Copy the SSH key to the bastion host
scp -i ${var.name_prefix}-key-${random_string.suffix.result}.pem ${var.name_prefix}-key-${random_string.suffix.result}.pem ec2-user@${module.bastion.public_dns}:/home/ec2-user/.

2) SSH to the bastion host
ssh -i ${var.name_prefix}-key-${random_string.suffix.result}.pem ec2-user@${module.bastion.public_dns}

3) SSH to the App Connectors
ssh -i ${var.name_prefix}-key-${random_string.suffix.result}.pem admin@<< AC mgmt IP >> -o "proxycommand ssh -W %h:%p -i ${var.name_prefix}-key-${random_string.suffix.result}.pem ec2-user@${module.bastion.public_dns}"
Note: Due to the dynamic nature of autoscaling groups, you will need to login to the AWS console and identify the private IP for each AC deployed and insert into the above command replacing "<< AC mgmt IP >>"
Note: If deploying via Amazon Linux 2 AMI instead of Zscaler AMI, replace username "admin" with "ec2-user"

VPC:
${module.network.vpc_id}

All AC AZs:
${join("\n", distinct(module.ac_asg.availability_zone))}

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
  description = "OAuth2 user codes from ASG instances. Use 'terraform output -json oauth_user_codes | jq -r' to view."
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

output "ssm_parameter_prefix" {
  description = "SSM Parameter Store prefix - instances create: {prefix}-{instance-id}"
  value       = local.ssm_parameter_prefix
}

output "oauth_token_count" {
  description = "Number of OAuth tokens found in SSM and passed to ZPA"
  value       = length(local.user_codes)
}
