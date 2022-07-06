data "aws_vpc" "selected" {
  id = var.vpc
}

# Create Security Group for App Connector
resource "aws_security_group" "ac-sg" {
  count       = var.ac_count
  name        = var.ac_count > 1 ? "${var.name_prefix}-ac-${count.index + 1}-sg-${var.resource_tag}" : "${var.name_prefix}-ac-sg-${var.resource_tag}"
  description = "Security group for App Connector-${count.index + 1} interface"
  vpc_id      = var.vpc

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

resource "aws_security_group_rule" "ac-node-ingress-ssh" {
  count             = var.ac_count
  description       = "Allow SSH to App Connector VM"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.ac-sg.*.id[count.index]
  cidr_blocks       = [data.aws_vpc.selected.cidr_block]
  type              = "ingress"
}