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


output "alb_security_group_id" {
  description = "FreshCart ALB security group ID"
  value       = module.security.alb_security_group_id
}

output "ec2_security_group_id" {
  description = "FreshCart EC2 security group ID"
  value       = module.security.ec2_security_group_id
}


output "backend_instance_id" {
  description = "FreshCart backend EC2 instance ID"
  value       = aws_instance.backend.id
}

output "backend_private_ip" {
  description = "Private IP address of the FreshCart backend"
  value       = aws_instance.backend.private_ip
}
