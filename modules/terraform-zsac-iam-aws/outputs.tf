output "iam_instance_profile_id" {
  description = "App Connector IAM Instance Profile"
  value       = data.aws_iam_instance_profile.ac_host_profile_selected[*].name
}

output "iam_instance_profile_arn" {
  description = "App Connector IAM Instance Profile ARN"
  value       = data.aws_iam_instance_profile.ac_host_profile_selected[*].arn
}
