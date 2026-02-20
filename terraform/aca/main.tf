module "resource_group" {
  source       = "../modules/resource-group"
  project_name = var.project_name
  location     = var.location
  environment  = var.environment
  tags         = var.tags
}

module "aca_env" {
  source              = "../modules/aca"
  project_name        = var.project_name
  resource_group_name = module.resource_group.name
  location            = var.location
  tags                = var.tags
}

module "infra" {
  source             = "./modules/infra"
  environment_id     = module.aca_env.environment_id
  resource_group     = module.resource_group.name
  postgres_password  = var.postgres_password
  rabbitmq_user      = var.rabbitmq_user
  rabbitmq_password  = var.rabbitmq_password
}

module "apps" {
  source            = "./modules/apps"
  environment_id    = module.aca_env.environment_id
  resource_group    = module.resource_group.name
  ghcr_username     = var.ghcr_username
  ghcr_token        = var.ghcr_token
  image_tag         = var.image_tag
  jwt               = local.jwt
  postgres_password = var.postgres_password
  rabbitmq_user     = var.rabbitmq_user
  rabbitmq_password = var.rabbitmq_password
  depends_on        = [module.infra]
}

module "observability" {
  source         = "./modules/observability"
  environment_id = module.aca_env.environment_id
  resource_group = module.resource_group.name
  ghcr_username  = var.ghcr_username
  ghcr_token     = var.ghcr_token
}