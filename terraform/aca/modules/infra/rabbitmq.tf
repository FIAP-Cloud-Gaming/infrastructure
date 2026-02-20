resource "azurerm_container_app" "rabbitmq" {
  name                         = "rabbitmq"
  container_app_environment_id = var.environment_id
  resource_group_name          = var.resource_group
  revision_mode                = "Single"

  template {
    min_replicas = 1
    max_replicas = 1

    container {
      name   = "rabbitmq"
      image  = "rabbitmq:4.1-management-alpine"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "RABBITMQ_DEFAULT_USER"
        value = var.rabbitmq_user
      }
      env {
        name  = "RABBITMQ_DEFAULT_PASS"
        value = var.rabbitmq_password
      }
    }
  }

  ingress {
    external_enabled = false
    target_port      = 5672
    transport        = "tcp"
    exposed_port     = 5672

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}