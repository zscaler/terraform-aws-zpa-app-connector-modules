# Zscaler App Connector / AWS EC2 Instance (Cloud Connector) Module

This module creates all AWS EC2 instance resources needed to deploy App Connector appliances.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.7, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.7.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.2.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.7.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_instance.ac_vm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_ami.appconnector](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ssm_parameter.amazon_linux_latest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ac_count"></a> [ac\_count](#input\_ac\_count) | Default number of App Connector appliances to create | `number` | `1` | no |
| <a name="input_ac_subnet_ids"></a> [ac\_subnet\_ids](#input\_ac\_subnet\_ids) | App Connector EC2 Instance subnet ID | `list(string)` | n/a | yes |
| <a name="input_acvm_instance_type"></a> [acvm\_instance\_type](#input\_acvm\_instance\_type) | App Connector Instance Type | `string` | `"m5.large"` | no |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | enable/disable public IP addresses on App Connector instances | `bool` | `false` | no |
| <a name="input_global_tags"></a> [global\_tags](#input\_global\_tags) | Populate any custom user defined tags from a map | `map(string)` | `{}` | no |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | IAM instance profile ID assigned to App Connector | `list(string)` | n/a | yes |
| <a name="input_instance_key"></a> [instance\_key](#input\_instance\_key) | SSH Key for instances | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A prefix to associate to all the App Connector module resources | `string` | `null` | no |
| <a name="input_resource_tag"></a> [resource\_tag](#input\_resource\_tag) | A tag to associate to all the App Connector module resources | `string` | `null` | no |
| <a name="input_security_group_id"></a> [security\_group\_id](#input\_security\_group\_id) | App Connector EC2 Instance management subnet id | `list(string)` | n/a | yes |
| <a name="input_use_zscaler_ami"></a> [use\_zscaler\_ami](#input\_use\_zscaler\_ami) | By default, App Connector will deploy via the Zscaler Latest AMI. Setting this to false will deploy the latest Amazon Linux 2 AMI instead | `bool` | `true` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | App Init data | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_availability_zone"></a> [availability\_zone](#output\_availability\_zone) | Instance Availability Zone |
| <a name="output_id"></a> [id](#output\_id) | Instance ID |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | Instance Private IP Address |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | Instance Public IP |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
