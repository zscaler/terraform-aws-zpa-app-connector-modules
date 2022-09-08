output "iam_instance_profile_id" {
  value = data.aws_iam_instance_profile.ac-host-profile-selected.*.name
}

output "iam_instance_profile_arn" {
  value = data.aws_iam_instance_profile.ac-host-profile-selected.*.arn
}