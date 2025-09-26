# This Terraform code does not deploy a real-world cloud environment.
# It is a temporary deployment intended solely to perform tests.
# For a quick start see the file main_test.go, which executes the terratest library.
#
# Core tests:
#   - Do various combinations of known inputs produce expected outputs?
#   - Can we discover a pre-existing security group?
#
# Boilerplate tests:
#   - Can we call the module twice?
#   - Can we test BYO (Bring Your Own) security group functionality?

# Random name allows parallel runs on the same cloud account.
resource "random_pet" "this" {
  prefix = "test-sg"
}

locals {
  name_prefix  = "test-sg-${random_pet.this.id}"
  resource_tag = random_pet.this.id
}

# Create a VPC for testing
module "vpc" {
  source = "../../modules/terraform-zsac-network-aws"

  name_prefix  = local.name_prefix
  resource_tag = local.resource_tag
  global_tags = {
    Environment = "test"
    Purpose     = "terratest"
  }
}

### Test Creating Security Groups ###

module "ac_sg" {
  source = "../../modules/terraform-zsac-sg-aws"

  name_prefix  = local.name_prefix
  resource_tag = local.resource_tag
  global_tags = {
    Environment = "test"
    Purpose     = "terratest"
  }
  vpc_id   = module.vpc.vpc_id
  sg_count = 2
}

### Test BYO Security Group ###

# Create a security group manually to test BYO functionality
resource "aws_security_group" "byo_sg" {
  name        = "${local.name_prefix}-byo-sg-${local.resource_tag}"
  description = "BYO Security Group for App Connector"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${local.name_prefix}-byo-sg-${local.resource_tag}"
    Environment = "test"
    Purpose     = "terratest"
  }
}

module "ac_sg_byo" {
  source = "../../modules/terraform-zsac-sg-aws"

  name_prefix  = local.name_prefix
  resource_tag = local.resource_tag
  global_tags = {
    Environment = "test"
    Purpose     = "terratest"
  }
  vpc_id                = module.vpc.vpc_id
  byo_security_group    = true
  byo_security_group_id = [aws_security_group.byo_sg.id]
}
