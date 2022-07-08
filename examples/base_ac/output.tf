locals {

  testbedconfig = <<TB

1) Copy the SSH key to the bastion host
scp -i ${var.name_prefix}-key-${random_string.suffix.result}.pem ${var.name_prefix}-key-${random_string.suffix.result}.pem centos@${module.bastion.public_dns}:/home/centos/.

2) SSH to the bastion host
ssh -i ${var.name_prefix}-key-${random_string.suffix.result}.pem centos@${module.bastion.public_dns}

3) SSH to the App Connector
ssh -i ${var.name_prefix}-key-${random_string.suffix.result}.pem admin@${module.ac-vm.private_ip[0]} -o "proxycommand ssh -W %h:%p -i ${var.name_prefix}-key-${random_string.suffix.result}.pem centos@${module.bastion.public_dns}"

All App Connector Management IPs. Replace private IP below with zsroot@"ip address" in ssh example command above.
${join("\n", module.ac-vm.private_ip)}

VPC: 
${aws_vpc.vpc1.id}

All AC AZs:
${join("\n", distinct(module.ac-vm.availability_zone))}

All AC Instance IDs:
${join("\n", module.ac-vm.id)}

All NAT GW IPs:
${join("\n", aws_nat_gateway.ngw.*.public_ip)}


TB
}

output "testbedconfig" {
  value = local.testbedconfig
}
