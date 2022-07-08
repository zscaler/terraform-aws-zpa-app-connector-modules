locals {

  testbedconfig = <<TB


VPC:         
${data.aws_vpc.selected.id}

All AC AZs:
${join("\n", distinct(module.ac-asg.availability_zone))}

All NAT GW IPs:
${join("\n", data.aws_nat_gateway.selected.*.public_ip)}

TB
}

output "testbedconfig" {
  value = local.testbedconfig
}


resource "local_file" "testbed" {
  content = local.testbedconfig
  filename = "testbed.txt"
}