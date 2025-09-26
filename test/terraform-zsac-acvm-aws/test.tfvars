# Test variables for Zscaler App Connector VM
name_prefix                 = "tacvm"
resource_tag                = "test"
aws_region                  = "us-west-2"
user_data                   = "#!/bin/bash\necho 'App Connector VM initialized'"
acvm_instance_type          = "t3.medium"
ami_id                      = [""]
ac_count                    = 2
associate_public_ip_address = false
imdsv2_enabled              = true
