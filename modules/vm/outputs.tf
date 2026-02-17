output "vm_name" {
  value = azurerm_linux_virtual_machine.main.name
}

output "admin_username" {
  value = var.admin_username
}

output "ssh_private_key" {
  value     = tls_private_key.ssh.private_key_pem
  sensitive = true
}
