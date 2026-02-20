resource "azurerm_container_app" "mongo" {
  name                         = "mongo"
  container_app_environment_id = var.environment_id
  resource_group_name          = var.resource_group
  revision_mode                = "Single"

  template {
    min_replicas = 1
    max_replicas = 1

    container {
      name   = "mongo"
      image  = "mongo:latest"
      cpu    = 0.5
      memory = "1Gi"
    }
  }

  ingress {
    external_enabled = false
    target_port      = 27017
    transport        = "tcp"
    exposed_port     = 27017

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}