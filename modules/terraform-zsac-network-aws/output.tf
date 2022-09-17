output "vpc_id" {
  value = data.aws_vpc.vpc-selected.id
}

output "ac_subnet_ids" {
  value = data.aws_subnet.ac-subnet-selected.*.id
}

output "public_subnet_ids" {
  value = aws_subnet.public-subnet.*.id
}

output "nat_gateway_ips" {
  value = data.aws_nat_gateway.ngw-selected.*.public_ip
}


