# Zscaler "base_ac_asg" deployment type

This deployment type is intended for greenfield/pov/lab purposes. It will deploy a fully functioning sandbox environment in a new VPC. Full set of resources provisioned listed below, but this will effectively create all network infrastructure dependencies for an AWS environment. Everything from "Base" deployment type (Creates 1 new VPC with one or more public subnets; one IGW; one or more NAT Gateways; one Bastion Host in the public subnet assigned an Elastic IP and routing to the IGW; and generates local key pair .pem file for ssh access)<br>

Additionally: Creates App Connector Autoscaling Group + Launch Template spanning all AC subnets routing to the NAT Gateway in their same AZ. The preferred deployment configuration are App Connectors in a private subnet. If you desire to deploy to a public subnet, setting variable "associate_public_ip_address" to true will enable the automatic dynamic public IPv4 address assignment and set the Route Table to default next-hop through IGW.<br> 

We are leveraging the [Zscaler ZPA Provider](https://github.com/zscaler/terraform-provider-zpa) to connect to your ZPA Admin console and provision a new App Connector Group + Provisioning Key. You can still run this template if deploying to an existing App Connector Group rather than creating a new one, but using the conditional create functionality from variable byo_provisioning_key and supplying to name of your provisioning key to variable byo_provisioning_key_name. In either deployment, this is fed directly into the userdata for bootstrapping.<br>

## How to deploy:

### Option 1 (guided):
Optional: Edit the terraform.tfvars file under your desired deployment type (ie: base_ac) to setup your App Connector Group (Details are documented inside the file)
From the examples directory, run the zsac bash script that walks to all required inputs.
- ./zsac up
- enter "greenfield"
- enter "base_ac_asg"
- follow the remainder of the authentication and configuration input prompts.
- script will detect client operating system and download/run a specific version of terraform in a temporary bin directory
- inputs will be validated and terraform init/apply will automatically exectute.
- verify all resources that will be created/modified and enter "yes" to confirm

### Option 2 (manual):
Modify/populate any required variable input values in base_ac_asg/terraform.tfvars file and save.

From ac_asg directory execute:
- terraform init
- terraform apply

## How to destroy:

### Option 1 (guided):
From the examples directory, run the zsac bash script that walks to all required inputs.
- ./zsac destroy

### Option 2 (manual):
From base_ac_asg directory execute:
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
| <a name="module_ac-asg"></a> [ac-asg](#module\_ac-asg) | ../../modules/terraform-zsac-asg-aws | n/a |
| <a name="module_ac-iam"></a> [ac-iam](#module\_ac-iam) | ../../modules/terraform-zsac-iam-aws | n/a |
| <a name="module_ac-sg"></a> [ac-sg](#module\_ac-sg) | ../../modules/terraform-zsac-sg-aws | n/a |
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
| <a name="input_ac_subnets"></a> [ac\_subnets](#input\_ac\_subnets) | App Connector Subnets to create in VPC. This is only required if you want to override the default subnets that this code creates via vpc\_cidr variable. | `list(string)` | `null` | no |
| <a name="input_acvm_instance_type"></a> [acvm\_instance\_type](#input\_acvm\_instance\_type) | App Connector Instance Type | `string` | `"m5a.xlarge"` | no |
| <a name="input_app_connector_group_country_code"></a> [app\_connector\_group\_country\_code](#input\_app\_connector\_group\_country\_code) | Optional: Country code of this App Connector Group. example 'US' | `string` | `""` | no |
| <a name="input_app_connector_group_description"></a> [app\_connector\_group\_description](#input\_app\_connector\_group\_description) | Optional: Description of the App Connector Group | `string` | `""` | no |
| <a name="input_app_connector_group_dns_query_type"></a> [app\_connector\_group\_dns\_query\_type](#input\_app\_connector\_group\_dns\_query\_type) | Whether to enable IPv4 or IPv6, or both, for DNS resolution of all applications in the App Connector Group | `string` | `"IPV4_IPV6"` | no |
| <a name="input_app_connector_group_enabled"></a> [app\_connector\_group\_enabled](#input\_app\_connector\_group\_enabled) | Whether this App Connector Group is enabled or not | `bool` | `true` | no |
| <a name="input_app_connector_group_latitude"></a> [app\_connector\_group\_latitude](#input\_app\_connector\_group\_latitude) | Latitude of the App Connector Group. Integer or decimal. With values in the range of -90 to 90 | `string` | `"37.3382082"` | no |
| <a name="input_app_connector_group_location"></a> [app\_connector\_group\_location](#input\_app\_connector\_group\_location) | location of the App Connector Group in City, State, Country format. example: 'San Jose, CA, USA' | `string` | `"San Jose, CA, USA"` | no |
| <a name="input_app_connector_group_longitude"></a> [app\_connector\_group\_longitude](#input\_app\_connector\_group\_longitude) | Longitude of the App Connector Group. Integer or decimal. With values in the range of -90 to 90 | `string` | `"-121.8863286"` | no |
| <a name="input_app_connector_group_name"></a> [app\_connector\_group\_name](#input\_app\_connector\_group\_name) | Name of the App Connector Group | `string` | `"aws-connector-group-tf"` | no |
| <a name="input_app_connector_group_override_version_profile"></a> [app\_connector\_group\_override\_version\_profile](#input\_app\_connector\_group\_override\_version\_profile) | Optional: Whether the default version profile of the App Connector Group is applied or overridden. Default: false | `bool` | `false` | no |
| <a name="input_app_connector_group_upgrade_day"></a> [app\_connector\_group\_upgrade\_day](#input\_app\_connector\_group\_upgrade\_day) | Optional: App Connectors in this group will attempt to update to a newer version of the software during this specified day. Default value: SUNDAY. List of valid days (i.e., SUNDAY, MONDAY, etc) | `string` | `"SUNDAY"` | no |
| <a name="input_app_connector_group_upgrade_time_in_secs"></a> [app\_connector\_group\_upgrade\_time\_in\_secs](#input\_app\_connector\_group\_upgrade\_time\_in\_secs) | Optional: App Connectors in this group will attempt to update to a newer version of the software during this specified time. Default value: 66600. Integer in seconds (i.e., 66600). The integer should be greater than or equal to 0 and less than 86400, in 15 minute intervals | `string` | `"66600"` | no |
| <a name="input_app_connector_group_version_profile_id"></a> [app\_connector\_group\_version\_profile\_id](#input\_app\_connector\_group\_version\_profile\_id) | Optional: ID of the version profile. To learn more, see Version Profile Use Cases. https://help.zscaler.com/zpa/configuring-version-profile | `string` | `"2"` | no |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | enable/disable public IP addresses on App Connector instances | `bool` | `false` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region. | `string` | `"us-west-2"` | no |
| <a name="input_az_count"></a> [az\_count](#input\_az\_count) | Default number of subnets to create based on availability zone input | `number` | `2` | no |
| <a name="input_bastion_nsg_source_prefix"></a> [bastion\_nsg\_source\_prefix](#input\_bastion\_nsg\_source\_prefix) | CIDR blocks of trusted networks for bastion host ssh access | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_byo_provisioning_key"></a> [byo\_provisioning\_key](#input\_byo\_provisioning\_key) | Bring your own App Connector Provisioning Key. Setting this variable to true will effectively instruct this module to not create any resources and only reference data resources from values provided in byo\_provisioning\_key\_name | `bool` | `false` | no |
| <a name="input_byo_provisioning_key_name"></a> [byo\_provisioning\_key\_name](#input\_byo\_provisioning\_key\_name) | Existing App Connector Provisioning Key name | `string` | `null` | no |
| <a name="input_enrollment_cert"></a> [enrollment\_cert](#input\_enrollment\_cert) | Get name of ZPA enrollment cert to be used for App Connector provisioning | `string` | `"Connector"` | no |
| <a name="input_health_check_grace_period"></a> [health\_check\_grace\_period](#input\_health\_check\_grace\_period) | The amount of time until EC2 Auto Scaling performs the first health check on new instances after they are put into service. Default is 5 minutes | `number` | `300` | no |
| <a name="input_launch_template_version"></a> [launch\_template\_version](#input\_launch\_template\_version) | Launch template version. Can be version number, `$Latest` or `$Default` | `string` | `"$Latest"` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | Maxinum number of App Connectors to maintain in Autoscaling group | `number` | `4` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | Mininum number of App Connectors to maintain in Autoscaling group | `number` | `2` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | The name prefix for all your resources | `string` | `"zsdemo"` | no |
| <a name="input_owner_tag"></a> [owner\_tag](#input\_owner\_tag) | populate custom owner tag attribute | `string` | `"zsac-admin"` | no |
| <a name="input_provisioning_key_association_type"></a> [provisioning\_key\_association\_type](#input\_provisioning\_key\_association\_type) | Specifies the provisioning key type for App Connectors or ZPA Private Service Edges. The supported values are CONNECTOR\_GRP and SERVICE\_EDGE\_GRP | `string` | `"CONNECTOR_GRP"` | no |
| <a name="input_provisioning_key_enabled"></a> [provisioning\_key\_enabled](#input\_provisioning\_key\_enabled) | Whether the provisioning key is enabled or not. Default: true | `bool` | `true` | no |
| <a name="input_provisioning_key_max_usage"></a> [provisioning\_key\_max\_usage](#input\_provisioning\_key\_max\_usage) | The maximum number of instances where this provisioning key can be used for enrolling an App Connector or Service Edge | `number` | `10` | no |
| <a name="input_provisioning_key_name"></a> [provisioning\_key\_name](#input\_provisioning\_key\_name) | Name of the provisioning key | `string` | `"aws-prov-key-tf"` | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | Public/NAT GW Subnets to create in VPC. This is only required if you want to override the default subnets that this code creates via vpc\_cidr variable. | `list(string)` | `null` | no |
| <a name="input_reuse_on_scale_in"></a> [reuse\_on\_scale\_in](#input\_reuse\_on\_scale\_in) | Specifies whether instances in the Auto Scaling group can be returned to the warm pool on scale in. | `bool` | `"false"` | no |
| <a name="input_target_cpu_util_value"></a> [target\_cpu\_util\_value](#input\_target\_cpu\_util\_value) | Target value number for autoscaling policy CPU utilization target tracking. ie: trigger a scale in/out to keep average CPU Utliization percentage across all instances at/under this number | `number` | `50` | no |
| <a name="input_target_tracking_metric"></a> [target\_tracking\_metric](#input\_target\_tracking\_metric) | The AWS ASG pre-defined target tracking metric type. App Connector recommends ASGAverageCPUUtilization | `string` | `"ASGAverageCPUUtilization"` | no |
| <a name="input_tls_key_algorithm"></a> [tls\_key\_algorithm](#input\_tls\_key\_algorithm) | algorithm for tls\_private\_key resource | `string` | `"RSA"` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPC IP CIDR Range. All subnet resources that might get created (public / app connector) are derived from this /16 CIDR. If you require creating a VPC smaller than /16, you may need to explicitly define all other subnets via public\_subnets and ac\_subnets variables | `string` | `"10.1.0.0/16"` | no |
| <a name="input_warm_pool_enabled"></a> [warm\_pool\_enabled](#input\_warm\_pool\_enabled) | If set to true, add a warm pool to the specified Auto Scaling group. See [warm\_pool](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group#warm_pool). | `bool` | `"false"` | no |
| <a name="input_warm_pool_max_group_prepared_capacity"></a> [warm\_pool\_max\_group\_prepared\_capacity](#input\_warm\_pool\_max\_group\_prepared\_capacity) | Specifies the total maximum number of instances that are allowed to be in the warm pool or in any state except Terminated for the Auto Scaling group. Ignored when 'warm\_pool\_enabled' is false | `number` | `null` | no |
| <a name="input_warm_pool_min_size"></a> [warm\_pool\_min\_size](#input\_warm\_pool\_min\_size) | Specifies the minimum number of instances to maintain in the warm pool. This helps you to ensure that there is always a certain number of warmed instances available to handle traffic spikes. Ignored when 'warm\_pool\_enabled' is false | `number` | `null` | no |
| <a name="input_warm_pool_state"></a> [warm\_pool\_state](#input\_warm\_pool\_state) | Sets the instance state to transition to after the lifecycle hooks finish. Valid values are: Stopped (default), Running or Hibernated. Ignored when 'warm\_pool\_enabled' is false | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_testbedconfig"></a> [testbedconfig](#output\_testbedconfig) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->