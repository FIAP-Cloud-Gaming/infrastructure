output "resource_group_name" {
  value = module.resource_group.name
}

output "environment_default_domain" {
  value = module.aca.default_domain
}

output "gateway_url" {
  value = "https://gateway-api.${module.aca.default_domain}"
}

output "grafana_url" {
  value = "https://grafana.${module.aca.default_domain}"
}