locals {

  testbedconfig = <<TB

1) Copy the SSH key to the bastion host
scp -i ${var.name_prefix}-key-${random_string.suffix.result}.pem ${var.name_prefix}-key-${random_string.suffix.result}.pem ec2-user@${module.bastion.public_dns}:/home/ec2-user/.

2) SSH to the bastion host
ssh -i ${var.name_prefix}-key-${random_string.suffix.result}.pem ec2-user@${module.bastion.public_dns}

3) SSH to the App Connector
ssh -i ${var.name_prefix}-key-${random_string.suffix.result}.pem admin@${module.ac-vm.private_ip[0]} -o "proxycommand ssh -W %h:%p -i ${var.name_prefix}-key-${random_string.suffix.result}.pem ec2-user@${module.bastion.public_dns}"

All AC Private IPs. Replace private IP below with admin@"ip address" in ssh example command above.
${join("\n", module.ac-vm.private_ip)}

VPC:         
${module.network.vpc_id}

All AC AZs:
${join("\n", distinct(module.ac-vm.availability_zone))}

All AC Instance IDs:
${join("\n", module.ac-vm.id)}

All AC Public IPs:
${join("\n", module.ac-vm.public_ip)}

All AC IAM Role ARNs:
${join("\n", module.ac-iam.iam_instance_profile_arn)}

All NAT GW IPs:
${join("\n", module.network.nat_gateway_ips)}

TB
}

output "testbedconfig" {
  value = local.testbedconfig
}

resource "local_file" "testbed" {
  content  = local.testbedconfig
  filename = "../testbed.txt"
}