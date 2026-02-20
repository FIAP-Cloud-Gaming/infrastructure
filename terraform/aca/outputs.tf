output "resource_group_name" {
  value = module.resource_group.name
}

output "environment_default_domain" {
  value = module.aca_env.default_domain
}

output "gateway_url" {
  value = "https://gateway-api.${module.aca_env.default_domain}"
}

output "grafana_url" {
  value = "https://grafana.${module.aca_env.default_domain}"
}