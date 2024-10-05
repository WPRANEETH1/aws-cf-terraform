variable "vpc_name" {
}

variable "vpc_id" {
}

variable "environment" {
}

variable "project" {
}

variable "tags" {
}

variable "region" {
}

variable "ec2_name" {
  type        = string
  description = "ec2"
}

variable "instance_type" {
  type        = string
  description = "t2.medium"
}

variable "ec2_subnets" {
  type        = list(string)
  description = "CIDRs for the ec2 subnets"
}

variable "nlb_subnets" {
  type        = list(string)
  description = "CIDRs for the nlb subnets"
}

variable "rds_endpoint" {
}

variable "mariadb_sg" {
}
