# Zscaler ZPA Provider App Connector Provisioning Key Module

This module provides the resources necessary to create a new ZPA App Connector Provisioning Key to be used with App Connector appliance deployment and provisioining.

There is a "BYO" option where you can conditionally create new or reference an existing provisioning key by name.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.7, < 2.0.0 |
| <a name="requirement_zpa"></a> [zpa](#requirement\_zpa) | ~> 2.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_zpa"></a> [zpa](#provider\_zpa) | ~> 2.6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [zpa_provisioning_key.provisioning_key](https://registry.terraform.io/providers/zscaler/zpa/latest/docs/resources/provisioning_key) | resource |
| [zpa_enrollment_cert.connector_cert](https://registry.terraform.io/providers/zscaler/zpa/latest/docs/data-sources/enrollment_cert) | data source |
| [zpa_provisioning_key.provisioning_key_selected](https://registry.terraform.io/providers/zscaler/zpa/latest/docs/data-sources/provisioning_key) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_connector_group_id"></a> [app\_connector\_group\_id](#input\_app\_connector\_group\_id) | ID of App Connector Group from zpa-app-connector-group module | `string` | `null` | no |
| <a name="input_byo_provisioning_key"></a> [byo\_provisioning\_key](#input\_byo\_provisioning\_key) | Bring your own App Connector Provisioning Key. Setting this variable to true will effectively instruct this module to not create any resources and only reference data resources from values provided in byo\_provisioning\_key\_name | `bool` | `false` | no |
| <a name="input_byo_provisioning_key_name"></a> [byo\_provisioning\_key\_name](#input\_byo\_provisioning\_key\_name) | Existing App Connector Provisioning Key name | `string` | `null` | no |
| <a name="input_enrollment_cert"></a> [enrollment\_cert](#input\_enrollment\_cert) | Get name of ZPA enrollment cert to be used for App Connector provisioning | `string` | `"Connector"` | no |
| <a name="input_provisioning_key_association_type"></a> [provisioning\_key\_association\_type](#input\_provisioning\_key\_association\_type) | Specifies the provisioning key type for App Connectors or ZPA Private Service Edges. The supported values are CONNECTOR\_GRP and SERVICE\_EDGE\_GRP | `string` | `"CONNECTOR_GRP"` | no |
| <a name="input_provisioning_key_enabled"></a> [provisioning\_key\_enabled](#input\_provisioning\_key\_enabled) | Whether the provisioning key is enabled or not. Default: true | `bool` | `true` | no |
| <a name="input_provisioning_key_max_usage"></a> [provisioning\_key\_max\_usage](#input\_provisioning\_key\_max\_usage) | The maximum number of instances where this provisioning key can be used for enrolling an App Connector or Service Edge | `number` | n/a | yes |
| <a name="input_provisioning_key_name"></a> [provisioning\_key\_name](#input\_provisioning\_key\_name) | Name of the provisioning key | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_provisioning_key"></a> [provisioning\_key](#output\_provisioning\_key) | ZPA Provisioning Key Output |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
