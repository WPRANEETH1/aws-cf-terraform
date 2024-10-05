variable "vpc_name" {
  default     = "aws-cf"
  type        = string
  description = "aws pcv prefix name"
}

variable "region" {
  default     = "us-east-1"
  type        = string
  description = "aws region"
}

variable "environment" {
  default     = "test"
  type        = string
  description = "application environment (test/ prod)"
}

variable "project" {
  default     = "assmt"
  type        = string
  description = "aws project name"
}
