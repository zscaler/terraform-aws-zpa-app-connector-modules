output "vpc_id" {
  description = "VPC ID Selected"
  value       = data.aws_vpc.vpc_selected.id
}

output "ac_subnet_ids" {
  description = "App Connector Subnet IDs"
  value       = data.aws_subnet.ac_subnet_selected[*].id
}

output "public_subnet_ids" {
  description = "Public Subnet ID"
  value       = aws_subnet.public_subnet[*].id
}

output "nat_gateway_ips" {
  description = "NAT Gateway Public IP"
  value       = data.aws_nat_gateway.ngw_selected[*].public_ip
}
