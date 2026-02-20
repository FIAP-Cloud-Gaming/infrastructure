resource "azurerm_container_app" "redis" {
  name                         = "redis"
  container_app_environment_id = var.environment_id
  resource_group_name          = var.resource_group
  revision_mode                = "Single"

  template {
    min_replicas = 1
    max_replicas = 1

    container {
      name   = "redis"
      image  = "redis:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  ingress {
    external_enabled = false
    target_port      = 6379
    transport        = "tcp"
    exposed_port     = 6379

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}