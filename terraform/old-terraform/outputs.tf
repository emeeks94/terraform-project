output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "private_subnet_id" {
  value = module.network.private_subnet_id
}

output "load_balancer_dns" {
  value = aws_lb.freshcart.dns_name
}

output "backend_instance_id" {
  value = aws_instance.backend.id
}