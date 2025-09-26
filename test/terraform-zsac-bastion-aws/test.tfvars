# Test variables for terraform-zsac-bastion-aws
aws_region                = "us-west-2"
name_prefix               = "tbas"
resource_tag              = "test"
instance_key              = "test-key"
instance_type             = "t3.micro"
bastion_nsg_source_prefix = ["0.0.0.0/0"]
iam_role_policy_ssmcore   = "AmazonSSMManagedInstanceCore"
