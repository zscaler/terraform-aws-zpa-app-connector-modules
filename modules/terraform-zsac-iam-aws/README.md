# Zscaler App Connector / AWS IAM Module

This module creates IAM Policies, Roles, and Instance Profile resources required for successful App Connector deployments. As part of Zscaler provided deployment templates most resources have conditional create options leveraged "byo" variables should a customer want to leverage the module outputs with data reference to resources that may already exist in their AWS environment.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.7, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.94.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.94.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.ac_host_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.ac_node_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_instance_profile.ac_host_profile_selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_instance_profile) | data source |
| [aws_iam_policy_document.instance_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_byo_iam"></a> [byo\_iam](#input\_byo\_iam) | Bring your own IAM Instance Profile for App Connector. Setting this variable to true will effectively instruct this module to not create any resources and only reference data resources from values provided in byo\_iam\_instance\_profile\_id | `bool` | `false` | no |
| <a name="input_byo_iam_instance_profile_id"></a> [byo\_iam\_instance\_profile\_id](#input\_byo\_iam\_instance\_profile\_id) | Existing IAM Instance Profile IDs for App Connector association | `list(string)` | `null` | no |
| <a name="input_global_tags"></a> [global\_tags](#input\_global\_tags) | Populate any custom user defined tags from a map | `map(string)` | `{}` | no |
| <a name="input_iam_count"></a> [iam\_count](#input\_iam\_count) | Default number IAM roles/policies/profiles to create | `number` | `1` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A prefix to associate to all the App Connector IAM module resources | `string` | `null` | no |
| <a name="input_resource_tag"></a> [resource\_tag](#input\_resource\_tag) | A tag to associate to all the App Connector IAM module resources | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_instance_profile_arn"></a> [iam\_instance\_profile\_arn](#output\_iam\_instance\_profile\_arn) | App Connector IAM Instance Profile ARN |
| <a name="output_iam_instance_profile_id"></a> [iam\_instance\_profile\_id](#output\_iam\_instance\_profile\_id) | App Connector IAM Instance Profile |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
