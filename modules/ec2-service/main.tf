# Fetch the most recent Amazon Linux 2 AMI (Amazon Machine Image) with Kernel 5.10
data "aws_ami" "linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.20230207.*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["137112412989"]
}

# Define the EC2 key pair using a public key file
resource "aws_key_pair" "key_pair" {
  key_name   = format("%s-%s", var.ec2_name, "keypair")
  public_key = file("./modules/ec2/id_rsa.pub")
}

# Create a launch template for the EC2 instance
resource "aws_launch_template" "launch_template" {
  name_prefix   = join("-", [var.vpc_name, var.project, var.environment, var.ec2_name, "launch-template"])
  image_id      = data.aws_ami.linux.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.key_pair.key_name
  iam_instance_profile {
    name = aws_iam_instance_profile.instance_profile.name
  }
  network_interfaces {
    security_groups = [aws_security_group.security_group.id]
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 50
    }
  }

  user_data = base64encode(templatefile("./modules/ec2-service/user_data.tpl", {
    DB_HOST = var.rds_endpoint
    DB_PORT = 3306
  }))

  tags = merge(
    {
      Name = join("-", [var.vpc_name, var.project, var.environment, var.ec2_name, "launch_template"]),
    },
    var.tags
  )
}

# Define a target group for the Network Load Balancer (NLB)
resource "aws_lb_target_group" "target_group" {
  name        = join("-", [var.project, var.environment, var.ec2_name, "tg"])
  port        = 80
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    protocol = "TCP"
  }
}

# Create a Network Load Balancer (NLB)
resource "aws_lb" "nlb" {
  name               = join("-", [var.project, var.environment, var.ec2_name, "nlb"])
  internal           = false
  load_balancer_type = "network"
  subnets            = var.nlb_subnets
  security_groups    = [aws_security_group.nlb_security_group.id]

  enable_deletion_protection = false

  tags = merge(
    {
      Name = join("-", [var.vpc_name, var.project, var.environment, "nlb-sg"]),
    },
    var.tags
  )
}

# Create a listener for the NLB to forward traffic to the target group
resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

# Create an Auto Scaling Group (ASG) for the EC2 instances
resource "aws_autoscaling_group" "autoscaling_group" {
  name                = join("-", [var.vpc_name, var.project, var.environment, var.ec2_name, "autoscaling-group"])
  desired_capacity    = 1
  max_size            = 3
  min_size            = 1
  vpc_zone_identifier = var.ec2_subnets
  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.target_group.arn]

  tag {
    key                 = "Name"
    value               = join("-", [var.vpc_name, var.project, var.environment, var.ec2_name, "autoscaling-group"])
    propagate_at_launch = true
  }
}
