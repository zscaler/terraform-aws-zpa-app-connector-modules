# Test outputs - these validate the module is working correctly
output "iam_instance_profile_id" {
  description = "IAM Instance Profile ID from module"
  value       = module.iam.iam_instance_profile_id
}

output "iam_instance_profile_arn" {
  description = "IAM Instance Profile ARN from module"
  value       = module.iam.iam_instance_profile_arn
}

output "iam_instance_profile_id_valid" {
  description = "Validation that IAM Instance Profile ID is valid"
  value       = length(module.iam.iam_instance_profile_id) > 0 ? "true" : "false"
}

output "iam_instance_profile_arn_valid" {
  description = "Validation that IAM Instance Profile ARN is valid"
  value       = length(module.iam.iam_instance_profile_arn) > 0 ? "true" : "false"
}

output "iam_instance_profile_count_correct" {
  description = "Validation that IAM Instance Profile count is correct"
  value       = length(module.iam.iam_instance_profile_id) == var.iam_count ? "true" : "false"
}

output "iam_instance_profile_arn_count_correct" {
  description = "Validation that IAM Instance Profile ARN count is correct"
  value       = length(module.iam.iam_instance_profile_arn) == var.iam_count ? "true" : "false"
}

output "test_variables_set_correctly" {
  description = "Validation that test variables are set correctly"
  value       = var.name_prefix != "" && var.resource_tag != "" ? "true" : "false"
}

output "iam_count_correct" {
  description = "Validation that IAM count is correct"
  value       = var.iam_count >= 1 ? "true" : "false"
}

output "byo_iam_set_correctly" {
  description = "Validation that BYO IAM is set correctly"
  value       = var.byo_iam == false ? "true" : "false"
}
