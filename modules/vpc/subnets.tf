resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.primary_vpc.id

  tags = merge(
    {
      Name = join("-", [var.vpc_name, var.project, var.environment, "pri-rtb"]),
    },
    var.tags
  )
}

resource "aws_route" "private_route" {
  count = var.create_natgw ? 1 : 0
  depends_on             = [aws_nat_gateway.nat_gateway]

  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway[count.index].id
}

resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnet_cidr_blocks)

  vpc_id            = aws_vpc.primary_vpc.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = join("", [var.region, var.availability_zones_ref[count.index]])

  tags = merge(
    {
      Name = join("-", [var.vpc_name, "private-sub", var.availability_zones_ref[count.index]]),
    },
    var.tags
  )
}

resource "aws_route_table_association" "private_route_table_association" {
  count = length(var.private_subnet_cidr_blocks)

  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

# *********************

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.primary_vpc.id

  tags = merge(
    {
      Name = join("-", [var.vpc_name, var.project, var.environment, "pub-rtb"]),
    },
    var.tags
  )
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnet_cidr_blocks)

  vpc_id                  = aws_vpc.primary_vpc.id
  cidr_block              = var.public_subnet_cidr_blocks[count.index]
  availability_zone       = join("", [var.region, var.availability_zones_ref[count.index]])
  map_public_ip_on_launch = true


  tags = merge(
    {
      Name = join("-", [var.vpc_name, "public-sub", var.availability_zones_ref[count.index]]),
    },
    var.tags
  )
}

resource "aws_route_table_association" "public_route_table_association" {
  count = length(var.public_subnet_cidr_blocks)

  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}
