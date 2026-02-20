locals {
  environment_id   = module.aca_env.environment_id
  resource_group   = module.resource_group.name
  ghcr_secret_name = "ghcr-token"

  jwt = {
    secret   = var.jwt_secret
    issuer   = "fcg-identity-api"
    audience = "fcg-services"
  }
}