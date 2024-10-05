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

variable "private_subnets" {
}

variable "security_groups_allowed" {
  description = "List of security groups allowed to access the RDS instance"
  type        = list(string)
  default     = []
}

variable "allocated_storage" {
  description = "Allocated storage in gibibytes"
  default     = 100
}

variable "username" {
  description = "Username for the master DB user"
}

variable "password" {
  description = "Password for the master DB user"
}

variable "instance_class" {
  description = "Instance type of the RDS instance"
  default     = "db.t4g.micro"
}
