################################################################################
# Locate Latest App Connector AMI by product code
################################################################################
data "aws_ami" "appconnector" {
  most_recent = true

  filter {
    name   = "product-code"
    values = ["3n2udvk6ba2lglockhnetlujo"]
  }

  owners = ["aws-marketplace"]
}


################################################################################
# Locate Latest Amazon Linux 2 AMI for instance use
################################################################################
data "aws_ssm_parameter" "amazon_linux_latest" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}


################################################################################
# Create App Connector VM
################################################################################
resource "aws_instance" "ac_vm" {
  count                       = var.ac_count
  ami                         = var.use_zscaler_ami == true ? data.aws_ami.appconnector.id : data.aws_ssm_parameter.amazon_linux_latest.value
  instance_type               = var.acvm_instance_type
  iam_instance_profile        = element(var.iam_instance_profile, count.index)
  vpc_security_group_ids      = [element(var.security_group_id, count.index)]
  subnet_id                   = element(var.ac_subnet_ids, count.index)
  key_name                    = var.instance_key
  associate_public_ip_address = var.associate_public_ip_address
  user_data                   = base64encode(var.user_data)

  tags = merge(var.global_tags,
    { Name = "${var.name_prefix}-ac-vm-${count.index + 1}-${var.resource_tag}" }
  )
}
