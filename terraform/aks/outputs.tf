output "resource_group_name" {
  value = module.resource_group.name
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.main.name
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive = true
}

output "host" {
  value     = azurerm_kubernetes_cluster.main.kube_config[0].host
  sensitive = true
}

output "get_credentials_command" {
  value = "az aks get-credentials --resource-group ${module.resource_group.name} --name ${azurerm_kubernetes_cluster.main.name}"
}
