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

resource "aws_eip" "jump_ip" {
  domain = "vpc"

  tags = merge(
    {
      Name = join("-", [var.region, var.ec2_name, "instance-eip"]),
    },
    var.tags
  )
}

resource "aws_key_pair" "key_pair" {
  key_name   = format("%s-%s", var.ec2_name, "keypair")
  public_key = file("./modules/ec2/id_rsa.pub")
}

resource "aws_instance" "instance" {
  instance_type               = var.instance_type
  ami                         = data.aws_ami.linux.id
  key_name                    = aws_key_pair.key_pair.id
  vpc_security_group_ids      = [aws_security_group.security_group.id]
  subnet_id                   = var.ec2_subnet[0]
  iam_instance_profile        = aws_iam_instance_profile.instance_profile.id
  associate_public_ip_address = var.public_ip_address

  tags = merge(
    {
      Name = join("-", [var.region, var.ec2_name, "instance"]),
    },
    var.tags
  )

  user_data = templatefile("./modules/ec2/user_data.tpl", {})

  root_block_device {
    volume_size = 50
  }
}

resource "aws_eip_association" "jump-eip-association" {
  depends_on = [aws_instance.instance]

  instance_id   = aws_instance.instance.id
  allocation_id = aws_eip.jump_ip.id
}
