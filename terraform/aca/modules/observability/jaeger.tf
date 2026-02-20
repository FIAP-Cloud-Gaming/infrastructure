resource "azurerm_container_app" "jaeger" {
  name                         = "jaeger"
  container_app_environment_id = var.environment_id
  resource_group_name          = var.resource_group
  revision_mode                = "Single"

  template {
    min_replicas = 1
    max_replicas = 1

    container {
      name   = "jaeger"
      image  = "jaegertracing/jaeger:latest"
      cpu    = 0.5
      memory = "1Gi"
    }
  }

  ingress {
    external_enabled = false
    target_port      = 4317
    transport        = "http2"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}