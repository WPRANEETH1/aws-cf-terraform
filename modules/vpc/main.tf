resource "aws_vpc" "primary_vpc" {
  cidr_block = var.cidr_block_primary

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    {
      Name = join("-", [var.vpc_name, var.project, var.environment]),
    },
    var.tags
  )
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.primary_vpc.id

  tags = merge(
    {
      Name = join("-", [var.vpc_name, var.project, var.environment, "igw"]),
    },
    var.tags
  )
}

resource "aws_eip" "nat_eip" {
  count  = var.create_natgw ? 1 : 0
  domain = "vpc"

  tags = merge(
    {
      Name = join("-", [var.vpc_name, var.project, var.environment, "eip"]),
    },
    var.tags
  )
}

resource "aws_nat_gateway" "nat_gateway" {
  count      = var.create_natgw ? 1 : 0
  depends_on = [aws_internet_gateway.internet_gateway]
  # count = length(var.public_subnet_cidr_blocks)  // comment for use first zone for reduce the code

  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = merge(
    {
      Name = join("-", [var.vpc_name, var.project, var.environment, var.availability_zones_ref[0], "natgw"]),
    },
    var.tags
  )
}
