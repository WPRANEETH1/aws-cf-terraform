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

variable "security_groups_allowed" {
  description = "List of security groups allowed to access the RDS instance"
  type        = list(string)
  default     = []
}

variable "instance_type" {
  type        = string
  description = "t2.medium"
}

variable "ec2_subnet" {
  type        = list(string)
  description = "CIDRs for the public subnets"
}

variable "public_ip_address" {
  default     = false
  type        = bool
  description = "Enable public Ips"
}
