output "resource_group_name" {
  value = module.resource_group.name
}

output "vm_public_ip" {
  value = azurerm_public_ip.main.ip_address
}

output "gateway_url" {
  value = "http://${azurerm_public_ip.main.ip_address}"
}

output "ssh_private_key" {
  value     = tls_private_key.ssh.private_key_pem
  sensitive = true
}

output "ssh_command" {
  value = "ssh -i key.pem ${var.admin_username}@${azurerm_public_ip.main.ip_address}"
}