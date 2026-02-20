resource "azurerm_container_app" "identity_api" {
  name                         = "identity-api"
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
      name   = "identity-api"
      image  = "ghcr.io/fiap-cloud-gaming/identity-api:${var.image_tag}"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "ASPNETCORE_ENVIRONMENT"
        value = "Production"
      }
      env {
        name  = "ConnectionStrings__IdentityDb"
        value = "Host=postgres;Port=5432;Database=identity_db;Username=postgres;Password=${var.postgres_password}"
      }
      env {
        name  = "ConnectionStrings__RabbitMQ"
        value = "amqp://${var.rabbitmq_user}:${var.rabbitmq_password}@rabbitmq:5672"
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
        name  = "JwtSettings__AccessTokenExpirationMinutes"
        value = "60"
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