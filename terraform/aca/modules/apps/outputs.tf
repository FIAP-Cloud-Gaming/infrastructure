output "gateway_api_name" {
  value = azurerm_container_app.gateway_api.name
}

output "identity_api_name" {
  value = azurerm_container_app.identity_api.name
}

output "catalog_api_name" {
  value = azurerm_container_app.catalog_api.name
}

output "payment_api_name" {
  value = azurerm_container_app.payment_api.name
}