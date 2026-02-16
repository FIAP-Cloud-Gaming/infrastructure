output "vm_name" {
  value = azurerm_linux_virtual_machine.main.name
}

output "admin_username" {
  value = var.admin_username
}