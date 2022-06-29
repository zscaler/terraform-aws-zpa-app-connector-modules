variable "name" {
  description = "Name of the App Connector instance."
  default     = null
  type        = string
}

variable "name-prefix" {
  description = "The name prefix for all your resources"
  default     = "zsdemo"
  type        = string
}

variable "resource-tag" {
  description = "A tag to associate to all the App Connector module resources"
  default     = "zsdemo"
}

# IAM Policy Variables
variable "iam_policy" {
  description = "Zscaler_SSM_Policy"
  default     = "Zscaler_SSM_Policy"
  type        = string
}

variable "aws_iam_role" {
  description = "Zscaler_SSM_IAM_Role"
  default     = "Zscaler_SSM_IAM_Role"
  type        = string
}

# App Connector version setup
variable "appconnector_ami_id" {
  description = <<-EOF
  Specific AMI ID to use for App Connector instance.
  If `null` (the default), `appconnector_version` and `appconnector_product_code` vars are used to determine a public image to use.
  EOF
  default     = null
  type        = string
}

variable "appconnector_version" {
  description = <<-EOF
  ZPA App Connector version to deploy.
  To list all available App Connector VM versions, run the command provided below.
  Please have in mind that the `product-code` may need to be updated - check the `zpa_product_code` variable for more information.
  ```
  aws ec2 describe-images --region ca-central-1 --filters "Name=product-code,Values=3n2udvk6ba2lglockhnetlujo" "Name=name,Values=zpa-connector*" --output json --query "Images[].Description" \| grep -o 'zpa-connector-.*' \| sort
  ```
  EOF
  default     = "2021.06"
  type        = string
}

variable "zpa_product_code" {
  description = <<-EOF
  Product code corresponding to a chosen App Connector license type model - by default - BYOL.
  Please refer to the:
  [ZPA App Connector documentation](https://help.zscaler.com/zpa/connector-deployment-guide-amazon-web-services)
  EOF
  default     = "3n2udvk6ba2lglockhnetlujo"
  type        = string
}

variable "iam_instance_profile" {
  description = "IAM instance profile."
  default     = null
  type        = string
}

variable instance_type {
  description = "App Connector Instance Type"
  default     = "t3.medium"
  validation {
          condition     = (
            var.instance_type == "t3.medium" ||
            var.instance_type == "t2.medium" ||
            var.instance_type == "m5.large"  ||
            var.instance_type == "c5.large"  ||
            var.instance_type == "c5a.large"
          )
          error_message = "Input instance_type must be set to an approved vm instance type."
      }
}

variable "ssh_key_name" {
  description = "Name of AWS keypair to associate with instances."
  type        = string
}

variable "path_to_public_key" {
  description = "path to the ssh public key"
  type        = string
}

variable "bootstrap_options" {
  default     = "user_data.sh"
  type        = string
}

variable "tags" {
  description = "Map of additional tags to apply to all resources."
  default     = {}
  type        = map(any)
}

variable "interfaces" {
  description = <<-EOF
  Map of the network interface specifications.
  If "mgmt-interface-swap" bootstrap option is enabled, ensure dataplane interface `device_index` is set to 0 and the firewall management interface `device_index` is set to 1.
  Available options:
  - `device_index`       = (Required|int) Determines order in which interfaces are attached to the instance. Interface with `0` is attached at boot time.
  - `subnet_id`          = (Required|string) Subnet ID to create the ENI in.
  - `name`               = (Optional|string) Name tag for the ENI. Defaults to instance name suffixed by map's key.
  - `description`        = (Optional|string) A descriptive name for the ENI.
  - `create_public_ip`   = (Optional|bool) Whether to create a public IP for the ENI. Defaults to false.
  - `eip_allocation_id`  = (Optional|string) Associate an existing EIP to the ENI.
  - `private_ips`        = (Optional|list) List of private IPs to assign to the ENI. If not set, dynamic allocation is used.
  - `public_ipv4_pool`   = (Optional|string) EC2 IPv4 address pool identifier.
  - `source_dest_check`  = (Optional|bool) Whether to enable source destination checking for the ENI. Defaults to false.
  - `security_group_ids` = (Optional|list) A list of Security Group IDs to assign to this interface. Defaults to null.

  Example:
  ```
  interfaces = {
    mgmt = {
      device_index       = 0
      subnet_id          = aws_subnet.mgmt.id
      name               = "mgmt"
      create_public_ip   = true
      source_dest_check  = true
      security_group_ids = ["sg-123456"]
    },
    public = {
      device_index     = 1
      subnet_id        = aws_subnet.public.id
      name             = "public"
      create_public_ip = true
    },
    private = {
      device_index = 2
      subnet_id    = aws_subnet.private.id
      name         = "private"
    },
  ]
  ```
  EOF
  # For now it's not possible to have a more strict definition of variable type, optional
  # object attributes are still experimental
  type = map(any)
}