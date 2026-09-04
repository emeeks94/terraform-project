variable "aws_region" {
  description = "AWS region where FreshCart will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the FreshCart VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability Zones for the FreshCart infrastructure"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "instance_type" {
  description = "EC2 instance type for the FreshCart backend server"
  type        = string
  default     = "t3.micro"
}

variable "checkout_api_image" {
  description = "FreshCart checkout-api Docker image"
  type        = string
}
