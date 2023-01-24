################################################################################
# Pull in VPC info
################################################################################
data "aws_vpc" "selected" {
  id = var.vpc_id
}


################################################################################
# Create Security Group and Rules for App Connector Interfaces
################################################################################
resource "aws_security_group" "ac_sg" {
  count       = var.byo_security_group == false ? var.sg_count : 0
  name        = var.sg_count > 1 ? "${var.name_prefix}-ac-${count.index + 1}-sg-${var.resource_tag}" : "${var.name_prefix}-ac-sg-${var.resource_tag}"
  description = "Security group for App Connector interface"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.global_tags,
    { Name = "${var.name_prefix}-ac-${count.index + 1}-sg-${var.resource_tag}" }
  )
}

# Or use existing Security Group ID
data "aws_security_group" "ac_sg_selected" {
  count = var.byo_security_group == false ? length(aws_security_group.ac_sg[*].id) : length(var.byo_security_group_id)
  id    = var.byo_security_group == false ? element(aws_security_group.ac_sg[*].id, count.index) : element(var.byo_security_group_id, count.index)
}


resource "aws_security_group_rule" "ac_node_ingress_ssh" {
  count             = var.byo_security_group == false ? var.sg_count : 0
  description       = "Allow SSH to App Connector VM only from within the VPC CIDR space"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.ac_sg[count.index].id
  cidr_blocks       = [data.aws_vpc.selected.cidr_block]
  type              = "ingress"
}
