# Zscaler "Base_ac_zpa" deployment type

This deployment type is intended for greenfield/pov/lab purposes. It will deploy a fully functioning sandbox environment in a new VPC. Full set of resources provisioned listed below, but this will effectively create all network infrastructure dependencies for an AWS environment. Everything from "Base" deployment type (Creates 1 new VPC with one or more public subnets; one IGW; one or more NAT Gateways; one Bastion Host in the public subnet assigned an Elastic IP and routing to the IGW; generates local key pair .pem file for ssh access)<br>

Additionally: Creates App Connector private subnets and App Connector VMs egressing through the NAT Gateways in their respective availability zones. If you desire to deploy to a public subnet, setting variable "associate_public_ip_address" to true will enable the automatic dynamic public IPv4 address assignment and set the Route Table to default next-hop through IGW.<br> 

The difference between this example deployment type and "base_ac" is that we are also leveraging the [Zscaler ZPA Provider](https://github.com/zscaler/terraform-provider-zpa) to connect to your ZPA Admin console and provision a new App Connector Group + Provisioning Key. This is fed directly into the userdata script from the terraform-zpa-app-connector-group module for bootstrapping; the same as if the key previously existed.


## How to deploy:

### Option 1 (guided):
From the examples directory, run the zsac bash script that walks to all required inputs.
- ./zsac up
- enter "greenfield"
- enter "base_ac_zpa"
- follow the remainder of the authentication and configuration input prompts.
- script will detect client operating system and download/run a specific version of terraform in a temporary bin directory
- inputs will be validated and terraform init/apply will automatically exectute.
- verify all resources that will be created/modified and enter "yes" to confirm

### Option 2 (manual):
Modify/populate any required variable input values in base_ac_zpa/terraform.tfvars file and save.

From base_ac directory execute:
- terraform init
- terraform apply

## How to destroy:

### Option 1 (guided):
From the examples directory, run the zsac bash script that walks to all required inputs.
- ./zsac destroy

### Option 2 (manual):
From base_ac_zpa directory execute:
- terraform destroy

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.7, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.7.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.2.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.1.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.3.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 3.4.0 |
| <a name="requirement_zpa"></a> [zpa](#requirement\_zpa) | ~> 2.3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.7.0 |
| <a name="provider_local"></a> [local](#provider\_local) | ~> 2.2.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.3.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | ~> 3.4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ac-iam"></a> [ac-iam](#module\_ac-iam) | ../../modules/terraform-zsac-iam-aws | n/a |
| <a name="module_ac-sg"></a> [ac-sg](#module\_ac-sg) | ../../modules/terraform-zsac-sg-aws | n/a |
| <a name="module_ac-vm"></a> [ac-vm](#module\_ac-vm) | ../../modules/terraform-zsac-acvm-aws | n/a |
| <a name="module_bastion"></a> [bastion](#module\_bastion) | ../../modules/terraform-zsac-bastion-aws | n/a |
| <a name="module_network"></a> [network](#module\_network) | ../../modules/terraform-zsac-network-aws | n/a |
| <a name="module_zpa-app-connector-group"></a> [zpa-app-connector-group](#module\_zpa-app-connector-group) | ../../modules/terraform-zpa-app-connector-group | n/a |
| <a name="module_zpa-provisioning-key"></a> [zpa-provisioning-key](#module\_zpa-provisioning-key) | ../../modules/terraform-zpa-provisioning-key | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_key_pair.deployer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [local_file.private_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.testbed](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.user-data-file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [tls_private_key.key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ac_count"></a> [ac\_count](#input\_ac\_count) | Default number of App Connector appliances to create | `number` | `1` | no |
| <a name="input_ac_subnets"></a> [ac\_subnets](#input\_ac\_subnets) | App Connector Subnets to create in VPC. This is only required if you want to override the default subnets that this code creates via vpc\_cidr variable. | `list(string)` | `null` | no |
| <a name="input_acvm_instance_type"></a> [acvm\_instance\_type](#input\_acvm\_instance\_type) | App Connector Instance Type | `string` | `"m5a.xlarge"` | no |
| <a name="input_app_connector_group_country_code"></a> [app\_connector\_group\_country\_code](#input\_app\_connector\_group\_country\_code) | Optional: Country code of this App Connector Group. example 'US' | `string` | `""` | no |
| <a name="input_app_connector_group_description"></a> [app\_connector\_group\_description](#input\_app\_connector\_group\_description) | Optional: Description of the App Connector Group | `string` | `""` | no |
| <a name="input_app_connector_group_dns_query_type"></a> [app\_connector\_group\_dns\_query\_type](#input\_app\_connector\_group\_dns\_query\_type) | Whether to enable IPv4 or IPv6, or both, for DNS resolution of all applications in the App Connector Group | `string` | `"IPV4_IPV6"` | no |
| <a name="input_app_connector_group_enabled"></a> [app\_connector\_group\_enabled](#input\_app\_connector\_group\_enabled) | Whether this App Connector Group is enabled or not | `bool` | `true` | no |
| <a name="input_app_connector_group_latitude"></a> [app\_connector\_group\_latitude](#input\_app\_connector\_group\_latitude) | Latitude of the App Connector Group. Integer or decimal. With values in the range of -90 to 90 | `string` | n/a | yes |
| <a name="input_app_connector_group_location"></a> [app\_connector\_group\_location](#input\_app\_connector\_group\_location) | location of the App Connector Group in City, State, Country format. example: 'San Jose, CA, USA' | `string` | n/a | yes |
| <a name="input_app_connector_group_longitude"></a> [app\_connector\_group\_longitude](#input\_app\_connector\_group\_longitude) | Longitude of the App Connector Group. Integer or decimal. With values in the range of -90 to 90 | `string` | n/a | yes |
| <a name="input_app_connector_group_name"></a> [app\_connector\_group\_name](#input\_app\_connector\_group\_name) | Name of the App Connector Group | `string` | n/a | yes |
| <a name="input_app_connector_group_override_version_profile"></a> [app\_connector\_group\_override\_version\_profile](#input\_app\_connector\_group\_override\_version\_profile) | Optional: Whether the default version profile of the App Connector Group is applied or overridden. Default: false | `bool` | `false` | no |
| <a name="input_app_connector_group_upgrade_day"></a> [app\_connector\_group\_upgrade\_day](#input\_app\_connector\_group\_upgrade\_day) | Optional: App Connectors in this group will attempt to update to a newer version of the software during this specified day. Default value: SUNDAY. List of valid days (i.e., SUNDAY, MONDAY, etc) | `string` | `"SUNDAY"` | no |
| <a name="input_app_connector_group_upgrade_time_in_secs"></a> [app\_connector\_group\_upgrade\_time\_in\_secs](#input\_app\_connector\_group\_upgrade\_time\_in\_secs) | Optional: App Connectors in this group will attempt to update to a newer version of the software during this specified time. Default value: 66600. Integer in seconds (i.e., 66600). The integer should be greater than or equal to 0 and less than 86400, in 15 minute intervals | `string` | `"66600"` | no |
| <a name="input_app_connector_group_version_profile_id"></a> [app\_connector\_group\_version\_profile\_id](#input\_app\_connector\_group\_version\_profile\_id) | Optional: ID of the version profile. To learn more, see Version Profile Use Cases. https://help.zscaler.com/zpa/configuring-version-profile | `string` | `"2"` | no |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | enable/disable public IP addresses on App Connector instances. Setting this to true will result in the following: Dynamic Public IP address on the App Connector VM Instance will be enabled; no EIP or NAT Gateway resources will be created; and the App Connector Route Table default route next-hop will be set as the IGW | `bool` | `false` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region. | `string` | `"us-west-2"` | no |
| <a name="input_az_count"></a> [az\_count](#input\_az\_count) | Default number of subnets to create based on availability zone input | `number` | `2` | no |
| <a name="input_bastion_nsg_source_prefix"></a> [bastion\_nsg\_source\_prefix](#input\_bastion\_nsg\_source\_prefix) | CIDR blocks of trusted networks for bastion host ssh access | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_enrollment_cert"></a> [enrollment\_cert](#input\_enrollment\_cert) | Get name of ZPA enrollment cert to be used for App Connector provisioning | `string` | `"Connector"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | The name prefix for all your resources | `string` | `"zsdemo"` | no |
| <a name="input_owner_tag"></a> [owner\_tag](#input\_owner\_tag) | populate custom owner tag attribute | `string` | `"zsac-admin"` | no |
| <a name="input_provisioning_key_association_type"></a> [provisioning\_key\_association\_type](#input\_provisioning\_key\_association\_type) | Specifies the provisioning key type for App Connectors or ZPA Private Service Edges. The supported values are CONNECTOR\_GRP and SERVICE\_EDGE\_GRP | `string` | `"CONNECTOR_GRP"` | no |
| <a name="input_provisioning_key_enabled"></a> [provisioning\_key\_enabled](#input\_provisioning\_key\_enabled) | Whether the provisioning key is enabled or not. Default: true | `bool` | `true` | no |
| <a name="input_provisioning_key_max_usage"></a> [provisioning\_key\_max\_usage](#input\_provisioning\_key\_max\_usage) | The maximum number of instances where this provisioning key can be used for enrolling an App Connector or Service Edge | `number` | n/a | yes |
| <a name="input_provisioning_key_name"></a> [provisioning\_key\_name](#input\_provisioning\_key\_name) | Name of the provisioning key | `string` | n/a | yes |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | Public/NAT GW Subnets to create in VPC. This is only required if you want to override the default subnets that this code creates via vpc\_cidr variable. | `list(string)` | `null` | no |
| <a name="input_reuse_iam"></a> [reuse\_iam](#input\_reuse\_iam) | Specifies whether the SG module should create 1:1 IAM per instance or 1 IAM for all instances | `bool` | `false` | no |
| <a name="input_reuse_security_group"></a> [reuse\_security\_group](#input\_reuse\_security\_group) | Specifies whether the SG module should create 1:1 security groups per instance or 1 security group for all instances | `bool` | `false` | no |
| <a name="input_tls_key_algorithm"></a> [tls\_key\_algorithm](#input\_tls\_key\_algorithm) | algorithm for tls\_private\_key resource | `string` | `"RSA"` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPC IP CIDR Range. All subnet resources that might get created (public / app connector) are derived from this /16 CIDR. If you require creating a VPC smaller than /16, you may need to explicitly define all other subnets via public\_subnets and ac\_subnets variables | `string` | `"10.1.0.0/16"` | no |
| <a name="input_zpa_client_id"></a> [zpa\_client\_id](#input\_zpa\_client\_id) | ZPA API Client ID. Reference: https://help.zscaler.com/zpa/about-api-keys#:~:text=An%20API%20key%20is%20required,from%20the%20API%20Keys%20page | `string` | n/a | yes |
| <a name="input_zpa_client_secret"></a> [zpa\_client\_secret](#input\_zpa\_client\_secret) | ZPA API Client Secret. Reference: https://help.zscaler.com/zpa/about-api-keys#:~:text=An%20API%20key%20is%20required,from%20the%20API%20Keys%20page | `string` | n/a | yes |
| <a name="input_zpa_customer_id"></a> [zpa\_customer\_id](#input\_zpa\_customer\_id) | ZPA API Customer ID. Reference: https://help.zscaler.com/zpa/about-api-keys#:~:text=An%20API%20key%20is%20required,from%20the%20API%20Keys%20page | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_testbedconfig"></a> [testbedconfig](#output\_testbedconfig) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->