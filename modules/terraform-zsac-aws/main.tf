data "aws_region" "current" {}

data "aws_vpc" "selected" {
  id = var.vpc
}

data "aws_ami" "appconnector" {
  most_recent = true

  filter {
    name   = "product-code"
    values = ["3n2udvk6ba2lglockhnetlujo"]
  }

  owners = ["aws-marketplace"]
}


# Create App Connector VM
resource "aws_instance" "ac-vm" {
  count                       = var.ac_count
  ami                         = data.aws_ami.appconnector.id
  instance_type               = var.acvm_instance_type
  iam_instance_profile        = element(var.iam_instance_profile, count.index)
  vpc_security_group_ids      = [element(var.security_group_id, count.index)]
  subnet_id                   = element(var.subnet_id, count.index)
  key_name                    = var.instance_key
  associate_public_ip_address = var.associate_public_ip_address
  user_data                   = base64encode(var.user_data)
  
  tags = merge(var.global_tags,
        { Name = "${var.name_prefix}-ac-vm-${count.index + 1}-${var.resource_tag}" }
  )
}