resource "aws_security_group" "nlb_security_group" {
  name   = join("-", [var.vpc_name, var.project, var.environment, "nlb-sg"])
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
  }

  tags = merge(
    {
      Name = join("-", [var.vpc_name, var.project, var.environment, "nlb-sg"]),
    },
    var.tags
  )
}

resource "aws_security_group" "security_group" {
  name   = join("-", [var.vpc_name, var.project, var.environment, var.ec2_name, "sg"])
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = join("-", [var.vpc_name, var.project, var.environment, var.ec2_name, "sg"]),
    },
    var.tags
  )
}

resource "aws_security_group_rule" "nlb_inbound" {
  description              = "Allow nlb to communicate with the ec2 Server"
  from_port                = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.security_group.id
  source_security_group_id = aws_security_group.nlb_security_group.id
  to_port                  = 80
  type                     = "ingress"
}

resource "aws_security_group_rule" "mariyadb_inbound" {
  description              = "Allow mariyadb to communicate with the ec2 Server"
  from_port                = 3306
  protocol                 = "tcp"
  security_group_id        = var.mariadb_sg.id
  source_security_group_id = aws_security_group.security_group.id
  to_port                  = 3306
  type                     = "ingress"
}