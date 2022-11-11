output "private_ip" {
  description = "Instance Private IP Address"
  value       = aws_instance.ac_vm[*].private_ip
}

output "availability_zone" {
  description = "Instance Availability Zone"
  value       = aws_instance.ac_vm[*].availability_zone
}

output "id" {
  description = "Instance ID"
  value       = aws_instance.ac_vm[*].id
}

output "public_ip" {
  description = "Instance Public IP"
  value       = aws_instance.ac_vm[*].public_ip
}
