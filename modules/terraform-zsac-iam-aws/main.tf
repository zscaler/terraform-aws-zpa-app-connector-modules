resource "aws_iam_role" "ac-iam-role" {
  count = var.iam_count
  name = var.iam_count > 1 ? "${var.name_prefix}-ac-${count.index + 1}-node-iam-role-${var.resource_tag}" : "${var.name_prefix}-ac-node-iam-role-${var.resource_tag}"
  
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  tags = merge(var.global_tags)
}

resource "aws_iam_role_policy_attachment" "SSMManagedInstanceCore" {
  count = var.iam_count
  policy_arn = "arn:aws:iam::aws:policy/${var.iam_role_policy_ssmcore}"
  role       = aws_iam_role.ac-iam-role.*.name[count.index]
}

resource "aws_iam_instance_profile" "ac-host-profile" {
  count      = var.iam_count
  name       = var.iam_count > 1 ? "${var.name_prefix}-ac-${count.index + 1}-host-profile-${var.resource_tag}" : "${var.name_prefix}-ac-host-profile-${var.resource_tag}"
  role       = aws_iam_role.ac-iam-role.*.name[count.index]

  tags = merge(var.global_tags)
}