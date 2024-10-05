variable "vpc_name" {
}

variable "environment" {
}

variable "project" {
}

variable "tags" {
}

variable "region" {
}

variable "cidr_block_primary" {
  type        = string
  description = "Primary CIDR block for the VPC"
}

variable "public_subnet_cidr_blocks" {
  type        = list(any)
  description = "Public Subnet block for the VPC"
}

variable "private_subnet_cidr_blocks" {
  type        = list(any)
  description = "Private Subnet block for the VPC"
}

variable "availability_zones_ref" {
  type        = list(any)
  description = "List of availability zones reference"
}

variable "create_natgw" {
  description = "Set to true to create the natgw, false to skip it."
  type        = bool
  default     = true
}
