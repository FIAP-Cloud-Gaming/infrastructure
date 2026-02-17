output "gateway_url" {
  description = "URL do Gateway API (entry point)"
  value       = "https://${azurerm_container_app.gateway_api.ingress[0].fqdn}"
}

output "rabbitmq_url" {
  description = "URL do RabbitMQ Management"
  value       = "https://${azurerm_container_app.rabbitmq.ingress[0].fqdn}"
}

output "grafana_url" {
  description = "URL do Grafana"
  value       = "https://${azurerm_container_app.grafana.ingress[0].fqdn}"
}

output "jaeger_url" {
  description = "URL do Jaeger (tracing)"
  value       = "https://${azurerm_container_app.jaeger.ingress[0].fqdn}"
}

output "elasticsearch_url" {
  description = "URL do Elasticsearch (interno)"
  value       = "https://${azurerm_container_app.elasticsearch.ingress[0].fqdn}"
}

output "environment_domain" {
  description = "Dominio padrao do Container Apps Environment"
  value       = module.container_apps.default_domain
}

output "demo_urls" {
  description = "Resumo de todos os links para apresentacao"
  value = <<-EOT

    ============================================
    FIAP Cloud Gaming - Dev Environment
    ============================================

    APIs (via Gateway):
      Swagger/Health:  https://${azurerm_container_app.gateway_api.ingress[0].fqdn}/health
      Auth:            https://${azurerm_container_app.gateway_api.ingress[0].fqdn}/api/auth
      Catalog:         https://${azurerm_container_app.gateway_api.ingress[0].fqdn}/api/catalog
      Payment:         https://${azurerm_container_app.gateway_api.ingress[0].fqdn}/api/payment

    Observabilidade:
      Grafana:         https://${azurerm_container_app.grafana.ingress[0].fqdn}
      Jaeger:          https://${azurerm_container_app.jaeger.ingress[0].fqdn}

    Infraestrutura:
      RabbitMQ:        https://${azurerm_container_app.rabbitmq.ingress[0].fqdn}

  EOT
}
