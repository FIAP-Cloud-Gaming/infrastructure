output "subnet_id" {
  description = "ID da subnet do Container Apps"
  value       = azurerm_subnet.container_apps.id
}

output "nsg_id" {
  description = "ID do Network Security Group"
  value       = azurerm_network_security_group.main.id
}

output "postgres_subnet_id" {
  description = "ID da subnet do PostgreSQL"
  value       = azurerm_subnet.postgres.id
}

output "private_dns_zone_id" {
  description = "ID da Private DNS Zone do PostgreSQL"
  value       = azurerm_private_dns_zone.postgres.id
}
