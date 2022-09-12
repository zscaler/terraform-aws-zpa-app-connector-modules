# Zscaler "ac" deployment type

This deployment type is intended for brownfield/production purposes. By default, it will create 1 new VPC with 2 public subnets and 2 App Connector private subnets; 1 IGW; 2 NAT Gateways; 2 App Connector VMs (1 per subnet/AZ) routing to the NAT Gateway in their same AZ; generates local key pair .pem file for ssh access; and generates local key pair .pem file for ssh access.

There are also "byo" variables providing the ability to use existing resources (VPC, subnets, IGW, NAT Gateways, IAM, Security Groups, etc.). The preferred deployment configuration are App Connectors in a private subnet. If you desire to deploy to a public subnet, setting variable "associate_public_ip_address" to true will enable the automatic dynamic public IPv4 address assignment and set the Route Table to default next-hop through IGW. 

## How to deploy:

### Option 1 (guided):
Optional - Edit examples/ac/terraform.tfvars with any "byo" values that already exist in your environment and save the file.
From the examples directory, run the zsac bash script that walks to all required inputs.
- ./zsac up
- enter "brownfield"
- enter "ac"
- follow the remainder of the authentication and configuration input prompts.
- script will detect client operating system and download/run a specific version of terraform in a temporary bin directory
- inputs will be validated and terraform init/apply will automatically exectute.
- verify all resources that will be created/modified and enter "yes" to confirm

### Option 2 (manual):
Modify/populate any required variable input values in ac/terraform.tfvars file and save.

From ac directory execute:
- terraform init
- terraform apply

## How to destroy:

### Option 1 (guided):
From the examples directory, run the zsac bash script that walks to all required inputs.
- ./zsac destroy

### Option 2 (manual):
From ac directory execute:
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
| <a name="module_network"></a> [network](#module\_network) | ../../modules/terraform-zsac-network-aws | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_key_pair.deployer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [local_file.testbed](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.user-data-file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [tls_private_key.key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ac_count"></a> [ac\_count](#input\_ac\_count) | Default number of App Connector appliances to create | `number` | `1` | no |
| <a name="input_ac_prov_key"></a> [ac\_prov\_key](#input\_ac\_prov\_key) | ZPA App Connector provisioning key | `string` | n/a | yes |
| <a name="input_ac_subnets"></a> [ac\_subnets](#input\_ac\_subnets) | App Connector Subnets to create in VPC. This is only required if you want to override the default subnets that this code creates via vpc\_cidr variable. | `list(string)` | `null` | no |
| <a name="input_acvm_instance_type"></a> [acvm\_instance\_type](#input\_acvm\_instance\_type) | App Connector Instance Type | `string` | `"m5a.xlarge"` | no |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | enable/disable public IP addresses on App Connector instances. Setting this to true will result in the following: Dynamic Public IP address on the App Connector VM Instance will be enabled; no EIP or NAT Gateway resources will be created; and the App Connector Route Table default route next-hop will be set as the IGW | `bool` | `false` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region. | `string` | `"us-west-2"` | no |
| <a name="input_az_count"></a> [az\_count](#input\_az\_count) | Default number of subnets to create based on availability zone input | `number` | `2` | no |
| <a name="input_bastion_nsg_source_prefix"></a> [bastion\_nsg\_source\_prefix](#input\_bastion\_nsg\_source\_prefix) | CIDR blocks of trusted networks for bastion host ssh access | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_byo_iam"></a> [byo\_iam](#input\_byo\_iam) | Bring your own IAM Instance Profile for App Connector | `bool` | `false` | no |
| <a name="input_byo_iam_instance_profile_id"></a> [byo\_iam\_instance\_profile\_id](#input\_byo\_iam\_instance\_profile\_id) | IAM Instance Profile ID for App Connector association | `list(string)` | `null` | no |
| <a name="input_byo_igw"></a> [byo\_igw](#input\_byo\_igw) | Bring your own AWS VPC for App Connector | `bool` | `false` | no |
| <a name="input_byo_igw_id"></a> [byo\_igw\_id](#input\_byo\_igw\_id) | User provided existing AWS Internet Gateway ID | `string` | `null` | no |
| <a name="input_byo_ngw"></a> [byo\_ngw](#input\_byo\_ngw) | Bring your own AWS NAT Gateway(s) App Connector | `bool` | `false` | no |
| <a name="input_byo_ngw_ids"></a> [byo\_ngw\_ids](#input\_byo\_ngw\_ids) | User provided existing AWS NAT Gateway IDs | `list(string)` | `null` | no |
| <a name="input_byo_security_group"></a> [byo\_security\_group](#input\_byo\_security\_group) | Bring your own Security Group for App Connector | `bool` | `false` | no |
| <a name="input_byo_security_group_id"></a> [byo\_security\_group\_id](#input\_byo\_security\_group\_id) | Management Security Group ID for App Connector association | `list(string)` | `null` | no |
| <a name="input_byo_subnet_ids"></a> [byo\_subnet\_ids](#input\_byo\_subnet\_ids) | User provided existing AWS Subnet IDs | `list(string)` | `null` | no |
| <a name="input_byo_subnets"></a> [byo\_subnets](#input\_byo\_subnets) | Bring your own AWS Subnets for App Connector | `bool` | `false` | no |
| <a name="input_byo_vpc"></a> [byo\_vpc](#input\_byo\_vpc) | Bring your own AWS VPC for App Connector | `bool` | `false` | no |
| <a name="input_byo_vpc_id"></a> [byo\_vpc\_id](#input\_byo\_vpc\_id) | User provided existing AWS VPC ID | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | The name prefix for all your resources | `string` | `"zsdemo"` | no |
| <a name="input_owner_tag"></a> [owner\_tag](#input\_owner\_tag) | populate custom owner tag attribute | `string` | `"zsac-admin"` | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | Public/NAT GW Subnets to create in VPC. This is only required if you want to override the default subnets that this code creates via vpc\_cidr variable. | `list(string)` | `null` | no |
| <a name="input_reuse_iam"></a> [reuse\_iam](#input\_reuse\_iam) | Specifies whether the SG module should create 1:1 IAM per instance or 1 IAM for all instances | `bool` | `false` | no |
| <a name="input_reuse_security_group"></a> [reuse\_security\_group](#input\_reuse\_security\_group) | Specifies whether the SG module should create 1:1 security groups per instance or 1 security group for all instances | `bool` | `false` | no |
| <a name="input_tls_key_algorithm"></a> [tls\_key\_algorithm](#input\_tls\_key\_algorithm) | algorithm for tls\_private\_key resource | `string` | `"RSA"` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPC IP CIDR Range. All subnet resources that might get created (public / app connector) are derived from this /16 CIDR. If you require creating a VPC smaller than /16, you may need to explicitly define all other subnets via public\_subnets and ac\_subnets variables | `string` | `"10.1.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_testbedconfig"></a> [testbedconfig](#output\_testbedconfig) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->