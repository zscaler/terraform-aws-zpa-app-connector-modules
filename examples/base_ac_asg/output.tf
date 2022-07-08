locals {

  testbedconfig = <<TB

1) Copy the SSH key to the bastion host
scp -i ${var.name_prefix}-key-${random_string.suffix.result}.pem ${var.name_prefix}-key-${random_string.suffix.result}.pem centos@${module.bastion.public_dns}:/home/centos/.

2) SSH to the bastion host
ssh -i ${var.name_prefix}-key-${random_string.suffix.result}.pem centos@${module.bastion.public_dns}

3) SSH to the App Connectors
ssh -i ${var.name_prefix}-key-${random_string.suffix.result}.pem admin@<< AC mgmt IP >> -o "proxycommand ssh -W %h:%p -i ${var.name_prefix}-key-${random_string.suffix.result}.pem centos@${module.bastion.public_dns}"

Note: Due to the dynamic nature of autoscaling groups, you will need to login to the AWS console and identify the mgmt IP for each AC deployed and insert into the above command replacing "<< AC mgmt IP >>"
Note: You can also login to the App Connectors directly from the AWS Console via Session Manager.


VPC: 
${aws_vpc.vpc1.id}

All AC AZs:
${join("\n", distinct(module.ac-asg.availability_zone))}

All NAT GW IPs:
${join("\n", aws_nat_gateway.ngw.*.public_ip)}

TB
}

output "testbedconfig" {
  value = local.testbedconfig
}

resource "local_file" "testbed" {
  content = local.testbedconfig
  filename = "testbed.txt"
}