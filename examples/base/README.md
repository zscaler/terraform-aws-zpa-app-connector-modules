# Zscaler "Base" deployment type

This deployment type is just for greenfield/POV reference and/or spoke workload testing. It does NOT deploy any App Connector appliances. Full set of resources provisioned list below, but this will effectively create all network infrastructure dependencies for an AWS environment. Creates 1 new VPC with 1 public subnet; 1 IGW; 1 NAT Gateway; 1 Bastion Host in the public subnet assigned an Elastic IP and routing to the IGW; generates local key pair .pem file for ssh access


## How to deploy:

### Option 1 (guided):
From the examples directory, run the zsac bash script that walks to all required inputs.
- ./zsac up
- enter "greenfield"
- enter "base"
- follow the remainder of the authentication and configuration input prompts.
- script will detect client operating system and download/run a specific version of terraform in a temporary bin directory
- inputs will be validated and terraform init/apply will automatically exectute.
- verify all resources that will be created/modified and enter "yes" to confirm

### Option 2 (manual):
Modify/populate any required variable input values in base/terraform.tfvars file and save.

From base directory execute:
- terraform init
- terraform apply

## How to destroy:

### Option 1 (guided):
From the examples directory, run the zsac bash script that walks to all required inputs.
- ./zsac destroy

### Option 2 (manual):
From base directory execute:
- terraform destroy

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.7, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.94.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.5.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.2.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.94.0 |
| <a name="provider_local"></a> [local](#provider\_local) | ~> 2.5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.6.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | ~> 4.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bastion"></a> [bastion](#module\_bastion) | ../../modules/terraform-zsac-bastion-aws | n/a |
| <a name="module_network"></a> [network](#module\_network) | ../../modules/terraform-zsac-network-aws | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_key_pair.deployer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [local_file.private_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.testbed](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [tls_private_key.key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region. | `string` | `"us-west-2"` | no |
| <a name="input_az_count"></a> [az\_count](#input\_az\_count) | Default number of subnets to create based on availability zone | `number` | `1` | no |
| <a name="input_bastion_nsg_source_prefix"></a> [bastion\_nsg\_source\_prefix](#input\_bastion\_nsg\_source\_prefix) | CIDR blocks of trusted networks for bastion host ssh access | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | The name prefix for all your resources | `string` | `"zsdemo"` | no |
| <a name="input_owner_tag"></a> [owner\_tag](#input\_owner\_tag) | populate custom owner tag attribute | `string` | `"zsac-admin"` | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | Public/NAT GW Subnets to create in VPC. This is only required if you want to override the default subnets that this code creates via vpc\_cidr variable. | `list(string)` | `null` | no |
| <a name="input_tls_key_algorithm"></a> [tls\_key\_algorithm](#input\_tls\_key\_algorithm) | algorithm for tls\_private\_key resource | `string` | `"RSA"` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPC IP CIDR Range. All subnet resources that might get created (public / app connector) are derived from this /16 CIDR. If you require creating a VPC smaller than /16, you may need to explicitly define all other subnets via public\_subnets and ac\_subnets variables | `string` | `"10.1.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_testbedconfig"></a> [testbedconfig](#output\_testbedconfig) | AWS Testbed results |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
