output "grafana_name" {
  value = azurerm_container_app.grafana.name
}

output "jaeger_name" {
  value = azurerm_container_app.jaeger.name
}

output "loki_name" {
  value = azurerm_container_app.loki.name
}