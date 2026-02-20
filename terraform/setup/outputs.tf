output "resource_group_name" {
  value = azurerm_resource_group.terraform-state.name
}

output "storage_account_name" {
  value = azurerm_storage_account.terraform-state.name
}

output "container_name" {
  value = azurerm_storage_container.terraform-state.name
}
