resource "azurerm_container_app" "gateway_api" {
  name                         = "gateway-api"
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
      name   = "gateway-api"
      image  = "ghcr.io/fiap-cloud-gaming/gateway-api:${var.image_tag}"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "ASPNETCORE_ENVIRONMENT"
        value = "Production"
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
        name  = "ReverseProxy__Clusters__identity-cluster__Destinations__identity-api__Address"
        value = "http://identity-api"
      }
      env {
        name  = "ReverseProxy__Clusters__catalog-cluster__Destinations__catalog-api__Address"
        value = "http://catalog-api"
      }
      env {
        name  = "ReverseProxy__Clusters__payment-cluster__Destinations__payment-api__Address"
        value = "http://payment-api"
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
    external_enabled = true
    target_port      = 8080
    transport        = "http"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}