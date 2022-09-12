locals {

  testbedconfig = <<TB


VPC:         
${module.network.vpc_id}

All AC AZs:
${join("\n", distinct(module.ac-asg.availability_zone))}

All NAT GW IPs:
${join("\n", module.network.nat_gateway_ips)}

All AC IAM Role ARNs:
${join("\n", module.ac-iam.iam_instance_profile_arn)}

TB
}

output "testbedconfig" {
  value = local.testbedconfig
}


resource "local_file" "testbed" {
  content  = local.testbedconfig
  filename = "../testbed.txt"
}