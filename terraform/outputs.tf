output "ubuntu_ami_id" {
  description = "Ubuntu AMI selected by Terraform"
  value       = data.aws_ami.ubuntu.id
}

output "vpc_id" {
  description = "FreshCart VPC ID"
  value       = module.network.vpc_id
}

output "public_subnet_a_id" {
  description = "FreshCart public subnet A ID"
  value       = module.network.public_subnet_a_id
}

output "public_subnet_b_id" {
  description = "FreshCart public subnet B ID"
  value       = module.network.public_subnet_b_id
}

output "private_subnet_a_id" {
  description = "FreshCart private subnet A ID"
  value       = module.network.private_subnet_a_id
}

output "nat_gateway_id" {
  description = "FreshCart NAT Gateway ID"
  value       = module.network.nat_gateway_id
}
