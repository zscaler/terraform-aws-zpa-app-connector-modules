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

## Create the app connector user_data file
locals {
  appuserdata = <<APPUSERDATA
#!/bin/bash
#Stop the App Connector service which was auto-started at boot time
systemctl stop zpa-connector
#Create a file from the App Connector provisioning key created in the ZPA Admin Portal
#Make sure that the provisioning key is between double quotes
echo "${var.ac_prov_key}" > /opt/zscaler/var/provision_key
#Run a yum update to apply the latest patches
yum update -y
#Start the App Connector service to enroll it in the ZPA cloud
systemctl start zpa-connector
#Wait for the App Connector to download latest build
sleep 60
#Stop and then start the App Connector for the latest build
systemctl stop zpa-connector
systemctl start zpa-connector
APPUSERDATA
}

# Create App Connector VM
resource "aws_instance" "ac-vm" {
  count                       = var.ac_count
  ami                         = data.aws_ami.appconnector.id
  instance_type               = var.acvm_instance_type
  iam_instance_profile        = element(var.iam_instance_profile, count.index)
  vpc_security_group_ids      = [element(var.security_group_id, count.index)]
  subnet_id                   = element(var.ac_subnet_ids, count.index)
  key_name                    = var.instance_key
  associate_public_ip_address = var.associate_public_ip_address
  user_data                   = base64encode(local.appuserdata)
  
  tags = merge(var.global_tags,
        { Name = "${var.name_prefix}-ac-vm-${count.index + 1}-${var.resource_tag}" }
  )
}