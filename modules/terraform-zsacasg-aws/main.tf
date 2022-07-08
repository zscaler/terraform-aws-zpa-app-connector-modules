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

# Create launch template for App Connector autoscaling group instance creation. Mgmt and service interface device indexes are swapped to support ASG + GWLB instance association
resource "aws_launch_template" "ac-launch-template" {
    count         = 1
    name          = "${var.name_prefix}-ac-launch-template-${var.resource_tag}"
    image_id      = data.aws_ami.appconnector.id
    instance_type = var.acvm_instance_type
    key_name      = var.instance_key
    user_data     = base64encode(local.appuserdata)
    
    iam_instance_profile {
      name = element(var.iam_instance_profile, count.index)
    }

    tag_specifications {
      resource_type = "instance"
      tags          = merge(var.global_tags, { Name = "${var.name_prefix}-acvm-asg-${var.resource_tag}" })
    }

    tag_specifications {
      resource_type = "network-interface"
      tags          = merge(var.global_tags, { Name = "${var.name_prefix}-acvm-nic-asg${var.resource_tag}" })
    }

    network_interfaces {
      description                 = "Interface for App Connector traffic"
      device_index                = 0
      security_groups             = [element(var.security_group_id, count.index)]
      associate_public_ip_address = var.associate_public_ip_address
    }

    lifecycle {
    create_before_destroy = true
  }
}

# Create Cloud Connector autoscaling group
resource "aws_autoscaling_group" "ac-asg" {
  name                      = "${var.name_prefix}-ac-asg-${var.resource_tag}"
  vpc_zone_identifier       = distinct(var.ac_subnet_ids)
  max_size                  = var.max_size
  min_size                  = var.min_size
  health_check_type         = "ELB"
  health_check_grace_period = var.health_check_grace_period

  launch_template {
    id      = aws_launch_template.ac-launch-template.*.id[0]
    version = var.launch_template_version
  }

  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupMinSize",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  dynamic "warm_pool" {
    for_each = var.warm_pool_enabled == true ? [var.warm_pool_enabled] : []
    content {
      pool_state                  = var.warm_pool_state
      min_size                    = var.warm_pool_min_size
      max_group_prepared_capacity = var.warm_pool_max_group_prepared_capacity
      instance_reuse_policy {
        reuse_on_scale_in = var.reuse_on_scale_in
      }
    }
  }

  lifecycle {
    ignore_changes = [load_balancers, desired_capacity, target_group_arns]
  }
}

# Create autoscaling group policy based on dynamic Target Tracking Scaling on average CPU
resource "aws_autoscaling_policy" "ac-asg-target-tracking-policy" {
  name                    = "${var.name_prefix}-ac-asg-target-policy-${var.resource_tag}"
  autoscaling_group_name  = aws_autoscaling_group.ac-asg.name
  policy_type             = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = var.target_tracking_metric
    }
    target_value = var.target_value
  }
}