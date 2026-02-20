resource "azurerm_container_app" "payment_api" {
  name                         = "payment-api"
  container_app_environment_id = var.environment_id
  resource_group_name          = var.resource_group
  revision_mode                = "Single"

  registry {
    server               = "ghcr.io"
    username             = var.ghcr_username
    password_secret_name = local.ghcr_secret_name
  }

  secret {
    name  = local.ghcr_secret_name
    value = var.ghcr_token
  }

  template {
    min_replicas = 1
    max_replicas = 1

    container {
      name   = "payment-api"
      image  = "ghcr.io/fiap-cloud-gaming/payment-api:${var.image_tag}"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "ASPNETCORE_ENVIRONMENT"
        value = "Production"
      }
      env {
        name  = "ConnectionStrings__PaymentDB"
        value = "Host=postgres;Port=5432;Database=payment_db;Username=postgres;Password=${var.postgres_password}"
      }
      env {
        name  = "ConnectionStrings__RabbitMQ"
        value = "amqp://${var.rabbitmq_user}:${var.rabbitmq_password}@rabbitmq:5672"
      }
      env {
        name  = "Elasticsearch__Uri"
        value = "http://elasticsearch"
      }
      env {
        name  = "JwtSettings__Secret"
        value = var.jwt.secret
      }
      env {
        name  = "JwtSettings__Issuer"
        value = var.jwt.issuer
      }
      env {
        name  = "JwtSettings__Audience"
        value = var.jwt.audience
      }
      env {
        name  = "Loki__Uri"
        value = "http://loki"
      }
      env {
        name  = "OTEL_EXPORTER_OTLP_ENDPOINT"
        value = "http://jaeger"
      }
    }
  }

  ingress {
    external_enabled = false
    target_port      = 8080
    transport        = "http"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}