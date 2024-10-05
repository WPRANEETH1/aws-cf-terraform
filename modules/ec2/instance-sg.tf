resource "aws_security_group" "security_group" {
  name   = join("-", [var.vpc_name, var.project, var.environment, var.ec2_name, "sg"])
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Conditionally create the ingress rule only if the security_groups_allowed variable is not empty
  dynamic "ingress" {
    for_each = length(var.security_groups_allowed) > 0 ? [1] : []

    content {
      from_port       = 22
      to_port         = 22
      protocol        = "TCP"
      security_groups = var.security_groups_allowed
    }
  }

  tags = merge(
    {
      Name = join("-", [var.vpc_name, var.project, var.environment, var.ec2_name, "sg"]),
    },
    var.tags
  )
}
