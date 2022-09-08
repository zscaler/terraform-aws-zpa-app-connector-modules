################################################################################
# Network Infrastructure Resources
################################################################################
# Identify availability zones available for region selected
data "aws_availability_zones" "available" {
  state = "available"
}


################################################################################
# VPC
################################################################################
# Create a new VPC
resource "aws_vpc" "vpc" {
  count                = var.byo_vpc == false ? 1 : 0
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = merge(var.global_tags,
    { Name = "${var.name_prefix}-vpc-${var.resource_tag}" }
  )
}

# Or reference an existing VPC
data "aws_vpc" "vpc-selected" {
  id = var.byo_vpc == false ? aws_vpc.vpc.*.id[0] : var.byo_vpc_id
}


################################################################################
# Internet Gateway
################################################################################
# Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
  count  = var.byo_igw == false ? 1 : 0
  vpc_id = data.aws_vpc.vpc-selected.id

  tags = merge(var.global_tags,
    { Name = "${var.name_prefix}-igw-${var.resource_tag}" }
  )
}

# Or reference an existing Internet Gateway
data "aws_internet_gateway" "igw-selected" {
  internet_gateway_id = var.byo_igw == false ? aws_internet_gateway.igw.*.id[0] : var.byo_igw_id
}


################################################################################
# NAT Gateway
################################################################################
# Create NAT Gateway and assign EIP per AZ. This will not be created if var.byo_ngw is set to True
resource "aws_eip" "eip" {
  count      = var.byo_ngw == false ? length(aws_subnet.public-subnet.*.id) : 0
  vpc        = true
  depends_on = [data.aws_internet_gateway.igw-selected]

  tags = merge(var.global_tags,
    { Name = "${var.name_prefix}-eip-az${count.index + 1}-${var.resource_tag}" }
  )
}

# Create 1 NAT Gateway per Public Subnet.
resource "aws_nat_gateway" "ngw" {
  count         = var.byo_ngw == false ? length(aws_subnet.public-subnet.*.id) : 0
  allocation_id = aws_eip.eip.*.id[count.index]
  subnet_id     = aws_subnet.public-subnet.*.id[count.index]
  depends_on    = [data.aws_internet_gateway.igw-selected]

  tags = merge(var.global_tags,
    { Name = "${var.name_prefix}-natgw-az${count.index + 1}-${var.resource_tag}" }
  )
}

# Or reference existing NAT Gateways
data "aws_nat_gateway" "ngw-selected" {
  count = var.byo_ngw == false ? length(aws_nat_gateway.ngw.*.id) : length(var.byo_ngw_ids)
  id    = var.byo_ngw == false ? aws_nat_gateway.ngw.*.id[count.index] : element(var.byo_ngw_ids, count.index)
}


################################################################################
# Public (NAT Gateway) Subnet & Route Tables
################################################################################
# Create equal number of Public/NAT Subnets to how many App Connector subnets exist. This will not be created if var.byo_ngw is set to True
resource "aws_subnet" "public-subnet" {
  count             = var.byo_ngw == false ? length(data.aws_subnet.ac-subnet-selected.*.id) : 0
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = var.public_subnets != null ? element(var.public_subnets, count.index) : cidrsubnet(data.aws_vpc.vpc-selected.cidr_block, 8, count.index + 101)
  vpc_id            = data.aws_vpc.vpc-selected.id

  tags = merge(var.global_tags,
    { Name = "${var.name_prefix}-public-subnet-${count.index + 1}-${var.resource_tag}" }
  )
}


# Create a public Route Table towards IGW. This will not be created if var.byo_ngw is set to True
resource "aws_route_table" "public-rt" {
  count  = var.byo_ngw == false ? 1 : 0
  vpc_id = data.aws_vpc.vpc-selected.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.igw-selected.internet_gateway_id
  }

  tags = merge(var.global_tags,
    { Name = "${var.name_prefix}-public-rt-${var.resource_tag}" }
  )
}


# Create equal number of Route Table associations to how many Public subnets exist. This will not be created if var.byo_ngw is set to True
resource "aws_route_table_association" "public-rt-association" {
  count          = var.byo_ngw == false ? length(aws_subnet.public-subnet.*.id) : 0
  subnet_id      = aws_subnet.public-subnet.*.id[count.index]
  route_table_id = aws_route_table.public-rt[0].id
}


################################################################################
# Private (App Connector) Subnet & Route Tables
################################################################################
# Create subnet for AC network in X availability zones per az_count variable
resource "aws_subnet" "ac-subnet" {
  count = var.byo_subnets == false ? var.az_count : 0

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = var.ac_subnets != null ? element(var.ac_subnets, count.index) : cidrsubnet(data.aws_vpc.vpc-selected.cidr_block, 8, count.index + 200)
  vpc_id            = data.aws_vpc.vpc-selected.id

  tags = merge(var.global_tags,
    { Name = "${var.name_prefix}-ac-subnet-${count.index + 1}-${var.resource_tag}" }
  )
}

# Or reference existing subnets
data "aws_subnet" "ac-subnet-selected" {
  count = var.byo_subnets == false ? var.az_count : length(var.byo_subnet_ids)
  id    = var.byo_subnets == false ? aws_subnet.ac-subnet.*.id[count.index] : element(var.byo_subnet_ids, count.index)
}


# Create Route Tables for AC subnets pointing to NAT Gateway resource in each AZ or however many were specified. Optionally, point directly to IGW for public deployments
resource "aws_route_table" "ac-rt" {
  count  = length(data.aws_subnet.ac-subnet-selected.*.id)
  vpc_id = data.aws_vpc.vpc-selected.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(data.aws_nat_gateway.ngw-selected.*.id, count.index)
  }

  tags = merge(var.global_tags,
    { Name = "${var.name_prefix}-ac-rt-${count.index + 1}-${var.resource_tag}" }
  )
}

# AC subnet Route Table Association
resource "aws_route_table_association" "ac-rt-asssociation" {
  count          = length(data.aws_subnet.ac-subnet-selected.*.id)
  subnet_id      = data.aws_subnet.ac-subnet-selected.*.id[count.index]
  route_table_id = aws_route_table.ac-rt.*.id[count.index]
}



