output "output_ec2_sg" {
  value = aws_security_group.security_group.id
}

output "output_nlb_dns_name" {
  value = aws_lb.nlb.dns_name
}
