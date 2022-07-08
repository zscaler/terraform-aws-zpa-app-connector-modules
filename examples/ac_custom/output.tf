locals {

  testbedconfig = <<TB


VPC:         
${data.aws_vpc.selected.id}

All AC AZs:
${join("\n", distinct(module.ac-vm.availability_zone))}

All AC Instance IDs:
${join("\n", module.ac-vm.id)}

All AC Management IPs.
${join("\n", module.ac-vm.private_ip)}

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