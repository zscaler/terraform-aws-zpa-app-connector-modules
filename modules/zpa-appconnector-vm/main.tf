# ZPA App Connector VM AMI ID lookup based on version (determined by product code)
data "aws_ami" "this" {
  count = var.appconnector_ami_id != null ? 0 : 1

  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "name"
    values = ["zpa-connector-${var.appconnector_version}*"]
  }
  filter {
    name   = "product-code"
    values = [var.zpa_product_code]
  }
}

data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"
    actions = [
      "kms:ListKeys",
      "kms:Decrypt",
      "tag:GetResources",
      "kms:ListAliases",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameter"]
    resources = ["arn:aws:ssm:*:*:parameter/ZSAC*"]
  }
}

data "aws_iam_policy_document" "app_connector_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    sid     = ""
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# 0. Random
resource "random_string" "suffix" {
  length  = 8
  upper   = false
  special = false
}

resource "aws_iam_policy" "this" {
  name        = "${var.iam_policy}-zpa-iam-${random_string.suffix.result}"
  description = var.iam_policy
  policy      = data.aws_iam_policy_document.this.json
}

resource "aws_iam_role" "this" {
  name               = "${var.aws_iam_role}-zpa-role-${random_string.suffix.result}"
  assume_role_policy = data.aws_iam_policy_document.app_connector_role_policy.json
}

resource "aws_iam_role_policy_attachment" "zscaler_policy_attachment" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
  name = "${var.name-prefix}-zpa-profile-${random_string.suffix.result}"
  role = aws_iam_role.this.name
}

# Create Parameter Store
# resource "aws_ssm_parameter" "this" {
#  count = var.create_secure_parameter? 1 : 0

#   name        = var.parameter_name
#   description = var.parameter_description
#   type        = "SecureString"
#   value       = var.zpa_provisioning_key
#   overwrite   = true
#   lifecycle {
#     ignore_changes = [
#       value,
#     ]
#   }
# }

# Create Parameter Store
# resource "aws_ssm_parameter" "this" {
#   count       = "${length(keys(var.configs))}"
#   name        = "/${var.prefix}/${element(keys(var.configs),count.index)}"
#   description = var.parameter_description
#   type        = "SecureString"
#   value       = var.zpa_provisioning_key
#   key_id      = aws_kms_key.this.key_id
#   overwrite   = true
#   lifecycle {
#     ignore_changes = [
#       value,
#     ]
#   }
# }

# Network Interfaces
resource "aws_network_interface" "this" {
  for_each = var.interfaces

  subnet_id         = each.value.subnet_id
  private_ips       = lookup(each.value, "private_ips", null)
  source_dest_check = lookup(each.value, "source_dest_check", false)
  security_groups   = lookup(each.value, "security_group_ids", null)
  description       = lookup(each.value, "description", null)
  tags              = merge(var.tags, { Name = coalesce(try(each.value.name, null), "${var.name}-${each.key}") })
}

# Create and/or associate EIPs
resource "aws_eip" "this" {
  for_each = { for k, v in var.interfaces : k => v if try(v.create_public_ip, false) }

  vpc               = true
  network_interface = aws_network_interface.this[each.key].id
  public_ipv4_pool  = lookup(each.value, "public_ipv4_pool", "amazon")
  tags              = merge(var.tags, { Name = coalesce(try(each.value.name, null), "${var.name}-${each.key}") })
}

resource "aws_eip_association" "this" {
  for_each = { for k, v in var.interfaces : k => v if try(v.eip_allocation_id, false) }

  allocation_id        = each.value.eip_allocation_id
  network_interface_id = aws_network_interface.this[each.key].id

  depends_on = [
    # Workaround for:
    # Error associating EIP: IncorrectInstanceState: The pending-instance-creation instance to which 'eni' is attached is not in a valid state for this operation
    aws_instance.this
  ]
}
resource "aws_key_pair" "this" {
  key_name   = "${var.ssh_key_name}-key-${random_string.suffix.result}"
  public_key  = file(var.path_to_public_key)
}

# Create ZPA instances
resource "aws_instance" "this" {

  ami                                  = coalesce(var.appconnector_ami_id, try(data.aws_ami.this[0].id, null))
  iam_instance_profile                 = aws_iam_instance_profile.iam_instance_profile.name
  instance_type                        = var.instance_type
  key_name                             = aws_key_pair.this.key_name
  user_data                            = file(var.bootstrap_options)

  # Attach primary interface to the instance
  dynamic "network_interface" {
    for_each = { for k, v in var.interfaces : k => v if v.device_index == 0 }

    content {
      device_index         = 0
      network_interface_id = aws_network_interface.this[network_interface.key].id
    }
  }

  tags = merge(var.tags, { Name = var.name })
}

resource "aws_network_interface_attachment" "this" {
  for_each = { for k, v in var.interfaces : k => v if v.device_index > 0 }

  instance_id          = aws_instance.this.id
  network_interface_id = aws_network_interface.this[each.key].id
  device_index         = each.value.device_index
}