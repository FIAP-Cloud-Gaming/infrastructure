module "resource_group" {
  source       = "../modules/resource-group"
  project_name = var.project_name
  location     = var.location
  environment  = var.environment
  tags         = var.tags
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = "${var.project_name}-aks"
  location            = var.location
  resource_group_name = module.resource_group.name
  dns_prefix          = "${var.project_name}-aks"
  kubernetes_version  = var.kubernetes_version
  tags                = var.tags

  default_node_pool {
    name                = "default"
    vm_size             = var.node_size
    node_count          = var.node_count
    auto_scaling_enabled = true
    min_count           = var.node_min_count
    max_count           = var.node_max_count
    os_disk_size_gb     = 64
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    dns_service_ip = "10.2.0.10"
    service_cidr   = "10.2.0.0/16"
  }
}
