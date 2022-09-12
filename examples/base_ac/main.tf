################################################################################
# Generate a unique random string for resource name assignment and key pair
################################################################################
resource "random_string" "suffix" {
  length  = 8
  upper   = false
  special = false
}


################################################################################
# Map default tags with values to be assigned to all tagged resources
################################################################################
locals {
  global_tags = {
    Owner                                                                                = var.owner_tag
    ManagedBy                                                                            = "terraform"
    Vendor                                                                               = "Zscaler"
    "zs-app-connector-cluster/${var.name_prefix}-cluster-${random_string.suffix.result}" = "shared"
  }
}


################################################################################
# The following lines generates a new SSH key pair and stores the PEM file 
# locally. The public key output is used as the instance_key passed variable 
# to the ec2 modules for admin_ssh_key public_key authentication.
# This is not recommended for production deployments. Please consider modifying 
# to pass your own custom public key file located in a secure location.   
################################################################################
resource "tls_private_key" "key" {
  algorithm = var.tls_key_algorithm
}

resource "aws_key_pair" "deployer" {
  key_name   = "${var.name_prefix}-key-${random_string.suffix.result}"
  public_key = tls_private_key.key.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.key.private_key_pem
  filename        = "../${var.name_prefix}-key-${random_string.suffix.result}.pem"
  file_permission = "0600"
}


################################################################################
# 1. Create/reference all network infrastructure resource dependencies for all 
#    child modules (vpc, igw, nat gateway, subnets, route tables)
################################################################################
module "network" {
  source                      = "../../modules/terraform-zsac-network-aws"
  name_prefix                 = var.name_prefix
  resource_tag                = random_string.suffix.result
  global_tags                 = local.global_tags
  az_count                    = var.az_count
  vpc_cidr                    = var.vpc_cidr
  public_subnets              = var.public_subnets
  ac_subnets                  = var.ac_subnets
  associate_public_ip_address = var.associate_public_ip_address
}


################################################################################
# 2. Create Bastion Host for workload and AC SSH jump access
################################################################################
module "bastion" {
  source                    = "../../modules/terraform-zsac-bastion-aws"
  name_prefix               = var.name_prefix
  resource_tag              = random_string.suffix.result
  global_tags               = local.global_tags
  vpc_id                    = module.network.vpc_id
  public_subnet             = module.network.public_subnet_ids[0]
  instance_key              = aws_key_pair.deployer.key_name
  bastion_nsg_source_prefix = var.bastion_nsg_source_prefix
}


################################################################################
# 3. Create specified number AC VMs per ac_count which will span equally across 
#    designated availability zones per az_count. E.g. ac_count set to 4 and 
#    az_count set to 2 will create 2x ACs in AZ1 and 2x ACs in AZ2
################################################################################
# Create the user_data file with necessary bootstrap variables for App Connector registration
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

# Write the file to local filesystem for storage/reference
resource "local_file" "user-data-file" {
  content  = local.appuserdata
  filename = "../user_data"
}

# Create specified number of AC appliances
module "ac-vm" {
  source                      = "../../modules/terraform-zsac-acvm-aws"
  ac_count                    = var.ac_count
  name_prefix                 = var.name_prefix
  resource_tag                = random_string.suffix.result
  global_tags                 = local.global_tags
  ac_subnet_ids               = module.network.ac_subnet_ids
  instance_key                = aws_key_pair.deployer.key_name
  user_data                   = local.appuserdata
  acvm_instance_type          = var.acvm_instance_type
  iam_instance_profile        = module.ac-iam.iam_instance_profile_id
  security_group_id           = module.ac-sg.ac_security_group_id
  associate_public_ip_address = var.associate_public_ip_address

  depends_on = [
    local_file.user-data-file,
  ]
}


################################################################################
# 4. Create IAM Policy, Roles, and Instance Profiles to be assigned to AC. 
#    Default behavior will create 1 of each IAM resource per AC VM. Set variable 
#    "reuse_iam" to true if you would like a single IAM profile created and 
#    assigned to ALL App Connectors instead.
################################################################################
module "ac-iam" {
  source       = "../../modules/terraform-zsac-iam-aws"
  iam_count    = var.reuse_iam == false ? var.ac_count : 1
  name_prefix  = var.name_prefix
  resource_tag = random_string.suffix.result
  global_tags  = local.global_tags
}


################################################################################
# 5. Create Security Group and rules to be assigned to the App Connector 
#    interface. Default behavior will create 1 of each SG resource per AC VM. 
#    Set variable "reuse_security_group" to true if you would like a single 
#    security group created and assigned to ALL App Connectors instead.
################################################################################
module "ac-sg" {
  source       = "../../modules/terraform-zsac-sg-aws"
  sg_count     = var.reuse_security_group == false ? var.ac_count : 1
  name_prefix  = var.name_prefix
  resource_tag = random_string.suffix.result
  global_tags  = local.global_tags
  vpc_id       = module.network.vpc_id
}