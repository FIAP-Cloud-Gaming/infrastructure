output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "resource_group_location" {
  value = azurerm_resource_group.main.location
}

output "public_ip_id" {
  value = azurerm_public_ip.main.id
}

output "public_ip_address" {
  value = azurerm_public_ip.main.ip_address
}

output "subnet_id" {
  value = azurerm_subnet.main.id
}