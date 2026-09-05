module "security" {
  source = "./modules/security"

  environment = var.environment
  vpc_id      = module.network.vpc_id
}
