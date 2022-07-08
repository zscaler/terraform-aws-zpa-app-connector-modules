# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Generate a unique random string for resource name assignment and key pair
resource "random_string" "suffix" {
  length  = 8
  upper   = false
  special = false
}

# Map default tags with values to be assigned to all tagged resources
locals {
  global_tags = {
    Owner       = var.owner_tag
    ManagedBy   = "terraform"
    Vendor      = "Zscaler"
    "zs-edge-connector-cluster/${var.name_prefix}-cluster-${random_string.suffix.result}" = "shared"
  }
}

############################################################################################################################
#### The following lines generates a new SSH key pair and stores the PEM file locally. The public key output is used    ####
#### as the instance_key passed variable to the ec2 modules for admin_ssh_key public_key authentication                 ####
#### This is not recommended for production deployments. Please consider modifying to pass your own custom              ####
#### public key file located in a secure location                                                                       ####
############################################################################################################################
# private key for login
resource "tls_private_key" "key" {
  algorithm   = var.tls_key_algorithm
}

resource "aws_key_pair" "deployer" {
  key_name   = "${var.name_prefix}-key-${random_string.suffix.result}"
  public_key = tls_private_key.key.public_key_openssh

  provisioner "local-exec" {
    command = <<EOF
      echo "${tls_private_key.key.private_key_pem}" > ${var.name_prefix}-key-${random_string.suffix.result}.pem
      chmod 0600 ${var.name_prefix}-key-${random_string.suffix.result}.pem
EOF
  }
}

# 1. Network Creation
# Identify availability zones available for region selected
data "aws_availability_zones" "available" {
  state = "available"
}

# Create a new VPC
resource "aws_vpc" "vpc1" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = merge(local.global_tags,
        { Name = "${var.name_prefix}-vpc1-${random_string.suffix.result}" }
  )
}


# Create an Internet Gateway
resource "aws_internet_gateway" "igw1" {
  vpc_id = aws_vpc.vpc1.id

  tags = merge(local.global_tags,
        { Name = "${var.name_prefix}-vpc1-igw-${random_string.suffix.result}" }
  )
}


# Create equal number of Public/NAT Subnets and Private/Workload Subnets to how many App Connector subnets exist. 
resource "aws_subnet" "pubsubnet" {
  count = length(aws_subnet.ac-subnet.*.id)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(aws_vpc.vpc1.cidr_block, 8, count.index + 101)
  vpc_id            = aws_vpc.vpc1.id

  tags = merge(local.global_tags,
        { Name = "${var.name_prefix}-vpc1-public-subnet-${count.index + 1}-${random_string.suffix.result}" }
  )
}


# Create a public Route Table towards IGW.
resource "aws_route_table" "routetablepublic1" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw1.id
  }

  tags = merge(local.global_tags,
        { Name = "${var.name_prefix}-igw-rt-${random_string.suffix.result}" }
  )
}

# Create equal number of Route Table associations to how many Public subnets exist. 
resource "aws_route_table_association" "routetablepublic1" {
  count = length(aws_subnet.pubsubnet.*.id)
  subnet_id      = aws_subnet.pubsubnet.*.id[count.index]
  route_table_id = aws_route_table.routetablepublic1.id
}


# Create NAT Gateway and assign EIP per AZ.
resource "aws_eip" "eip" {
  count      = length(aws_subnet.pubsubnet.*.id)
  vpc        = true
  depends_on = [aws_internet_gateway.igw1]

  tags = merge(local.global_tags,
        { Name = "${var.name_prefix}-eip-az${count.index + 1}-${random_string.suffix.result}" }
  )
}


# Create 1 NAT Gateway per Public Subnet.
resource "aws_nat_gateway" "ngw" {
  count = length(aws_subnet.pubsubnet.*.id)
  allocation_id = aws_eip.eip.*.id[count.index]
  subnet_id     = aws_subnet.pubsubnet.*.id[count.index]
  depends_on    = [aws_internet_gateway.igw1]
  
  tags = merge(local.global_tags,
        { Name = "${var.name_prefix}-vpc1-natgw-az${count.index + 1}-${random_string.suffix.result}" }
  )
}



# 2. Create Bastion Host
module "bastion" {
  source        = "../../modules/terraform-zsbastion-aws"
  name_prefix   = var.name_prefix
  resource_tag  = random_string.suffix.result
  global_tags   = local.global_tags
  vpc           = aws_vpc.vpc1.id
  public_subnet = aws_subnet.pubsubnet.0.id
  instance_key  = aws_key_pair.deployer.key_name
}


# 3. Create App Connector network, routing, and appliance
# Create subnet for App Connector network in X availability zones per az_count variable
resource "aws_subnet" "ac-subnet" {
  count = var.az_count

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(aws_vpc.vpc1.cidr_block, 8, count.index + 220)
  vpc_id            = aws_vpc.vpc1.id

  tags = merge(local.global_tags,
        { Name = "${var.name_prefix}-vpc1-ac-subnet-${count.index + 1}-${random_string.suffix.result}" }
  )
}


# Create Route Tables for AC subnets pointing to NAT Gateway resource in each AZ
resource "aws_route_table" "ac-rt" {
  count = length(aws_subnet.ac-subnet.*.id)
  vpc_id = aws_vpc.vpc1.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.ngw.*.id, count.index)
  }

  tags = merge(local.global_tags,
        { Name = "${var.name_prefix}-ac-rt-ngw-${count.index + 1}-${random_string.suffix.result}" }
  )
}


# AC subnet NATGW Route Table Association
resource "aws_route_table_association" "ac-rt-asssociation" {
  count          = length(aws_subnet.ac-subnet.*.id)
  subnet_id      = aws_subnet.ac-subnet.*.id[count.index]
  route_table_id = aws_route_table.ac-rt.*.id[count.index]
}


# Create X AC VMs per ac_count which will span equally across designated availability zones per az_count
# E.g. ac_count set to 4 and az_count set to 2 will create 2x App Connectors in AZ1 and 2x App Connectors in AZ2
module "ac-vm" {
  source                      = "../../modules/terraform-zsac-aws"
  ac_count                    = var.ac_count
  name_prefix                 = var.name_prefix
  resource_tag                = random_string.suffix.result
  global_tags                 = local.global_tags
  vpc                         = aws_vpc.vpc1.id
  ac_subnet_ids               = aws_subnet.ac-subnet.*.id
  instance_key                = aws_key_pair.deployer.key_name
  ac_prov_key                 = var.ac_prov_key
  acvm_instance_type          = var.acvm_instance_type
  iam_instance_profile        = module.ac-iam.iam_instance_profile_id
  security_group_id           = module.ac-sg.security_group_id
  associate_public_ip_address = var.associate_public_ip_address
}


module "ac-iam" {
  source        = "../../modules/terraform-zsac-iam-aws"
  iam_count     = var.reuse_iam == false ? var.ac_count : 1
  name_prefix   = var.name_prefix
  resource_tag  = random_string.suffix.result
  global_tags   = local.global_tags
}


module "ac-sg" {
  source        = "../../modules/terraform-zsac-sg-aws"
  sg_count      = var.reuse_security_group == false ? var.ac_count : 1
  name_prefix   = var.name_prefix
  resource_tag  = random_string.suffix.result
  global_tags   = local.global_tags
  vpc           = aws_vpc.vpc1.id
}


