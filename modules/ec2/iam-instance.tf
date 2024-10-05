data "aws_iam_policy_document" "policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "iam_role" {
  name                  = join("-", [var.region, var.ec2_name, "instance-role"])
  path                  = "/"
  assume_role_policy    = data.aws_iam_policy_document.policy_document.json
  force_detach_policies = false
  max_session_duration  = 3600

  tags = merge(
    {
      Name = join("-", [var.region, var.ec2_name, "instance-role"]),
    },
    var.tags
  )
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = join("-", [var.region, var.ec2_name, "instance-role"])
  path = "/"
  role = aws_iam_role.iam_role.id
}

data "aws_iam_policy" "ssm_instance_access_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role       = aws_iam_role.iam_role.name
  policy_arn = data.aws_iam_policy.ssm_instance_access_policy.arn
}
