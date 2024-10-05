output "output_vpc_id" {
  value = aws_vpc.primary_vpc.id
}

output "output_vpc_name" {
  value = aws_vpc.primary_vpc.tags["Name"]
}

output "output_private_subnets" {
  value = aws_subnet.private_subnet[*].id
}

output "output_public_subnets" {
  value = aws_subnet.public_subnet[*].id
}
