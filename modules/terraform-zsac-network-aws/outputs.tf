output "vpc_id" {
  description = "VPC ID Selected"
  value       = try(data.aws_vpc.vpc_selected[0].id, aws_vpc.vpc[0].id)
}

output "ac_subnet_ids" {
  description = "App Connector Subnet IDs"
  value       = data.aws_subnet.ac_subnet_selected[*].id
}

output "ac_route_table_ids" {
  description = "App Connector Route Table IDs"
  value       = [for rt in aws_route_table.ac_rt : rt.id]
}

output "public_subnet_ids" {
  description = "Public Subnet ID"
  value       = aws_subnet.public_subnet[*].id
}

output "public_route_table_id" {
  description = "Public Route Table ID"
  value       = var.byo_ngw == false ? aws_route_table.public_rt[0].id : null
}

output "nat_gateway_ips" {
  description = "NAT Gateway Public IP"
  value       = data.aws_nat_gateway.ngw_selected[*].public_ip
}
