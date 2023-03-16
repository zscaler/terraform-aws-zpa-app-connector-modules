################################################################################
# Create App Connector VM
################################################################################
resource "aws_instance" "ac_vm" {
  count                       = var.ac_count
  ami                         = element(var.ami_id, count.index)
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
