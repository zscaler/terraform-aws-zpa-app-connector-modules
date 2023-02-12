output "ac_security_group_id" {
  description = "App Connector Security Group ID"
  value       = data.aws_security_group.ac_sg_selected[*].id
}

output "ac_security_group_arn" {
  description = "App Connector Security Group ARN"
  value       = data.aws_security_group.ac_sg_selected[*].arn
}
