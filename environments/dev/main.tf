# ==================================================
# Modules base
# ==================================================

module "resource_group" {
  source       = "../../modules/resource-group"
  project_name = var.project_name
  location     = var.location
  environment  = var.environment
  tags         = var.tags
}

module "container_apps" {
  source              = "../../modules/container-apps"
  project_name        = var.project_name
  resource_group_name = module.resource_group.name
  location            = var.location
  tags                = var.tags
}

# ==================================================
# Locals (valores reutilizados)
# ==================================================

locals {
  environment_id   = module.container_apps.environment_id
  resource_group   = module.resource_group.name
  ghcr_secret_name = "ghcr-token"
}

# ==================================================
# Infrastructure: PostgreSQL x3
# ==================================================

resource "azurerm_container_app" "postgres_identity" {
  name                         = "postgres-identity"
  container_app_environment_id = local.environment_id
  resource_group_name          = local.resource_group
  revision_mode                = "Single"

  template {
    min_replicas = 1
    max_replicas = 1

    container {
      name   = "postgres"
      image  = "postgres:18.1-alpine"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "POSTGRES_USER"
        value = "postgres"
      }
      env {
        name  = "POSTGRES_PASSWORD"
        value = "postgres"
      }
      env {
        name  = "POSTGRES_DB"
        value = "identity_db"
      }
    }
  }

  ingress {
    external_enabled = false
    target_port      = 5432
    transport        = "tcp"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

resource "azurerm_container_app" "postgres_catalog" {
  name                         = "postgres-catalog"
  container_app_environment_id = local.environment_id
  resource_group_name          = local.resource_group
  revision_mode                = "Single"

  template {
    min_replicas = 1
    max_replicas = 1

    container {
      name   = "postgres"
      image  = "postgres:18.1-alpine"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "POSTGRES_USER"
        value = "postgres"
      }
      env {
        name  = "POSTGRES_PASSWORD"
        value = "postgres"
      }
      env {
        name  = "POSTGRES_DB"
        value = "catalog_db"
      }
    }
  }

  ingress {
    external_enabled = false
    target_port      = 5432
    transport        = "tcp"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

resource "azurerm_container_app" "postgres_payment" {
  name                         = "postgres-payment"
  container_app_environment_id = local.environment_id
  resource_group_name          = local.resource_group
  revision_mode                = "Single"

  template {
    min_replicas = 1
    max_replicas = 1

    container {
      name   = "postgres"
      image  = "postgres:18.1-alpine"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "POSTGRES_USER"
        value = "postgres"
      }
      env {
        name  = "POSTGRES_PASSWORD"
        value = "postgres"
      }
      env {
        name  = "POSTGRES_DB"
        value = "payment_db"
      }
    }
  }

  ingress {
    external_enabled = false
    target_port      = 5432
    transport        = "tcp"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

# ==================================================
# Infrastructure: MongoDB, Redis, RabbitMQ
# ==================================================

resource "azurerm_container_app" "mongo" {
  name                         = "mongo"
  container_app_environment_id = local.environment_id
  resource_group_name          = local.resource_group
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

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

resource "azurerm_container_app" "redis" {
  name                         = "redis"
  container_app_environment_id = local.environment_id
  resource_group_name          = local.resource_group
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

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

resource "azurerm_container_app" "elasticsearch" {
  name                         = "elasticsearch"
  container_app_environment_id = local.environment_id
  resource_group_name          = local.resource_group
  revision_mode                = "Single"

  template {
    min_replicas = 1
    max_replicas = 1

    container {
      name   = "elasticsearch"
      image  = "docker.elastic.co/elasticsearch/elasticsearch:8.17.0"
      cpu    = 1
      memory = "2Gi"

      env {
        name  = "discovery.type"
        value = "single-node"
      }
      env {
        name  = "xpack.security.enabled"
        value = "false"
      }
      env {
        name  = "ES_JAVA_OPTS"
        value = "-Xms512m -Xmx512m"
      }
    }
  }

  ingress {
    external_enabled = false
    target_port      = 9200
    transport        = "http"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

resource "azurerm_container_app" "rabbitmq" {
  name                         = "rabbitmq"
  container_app_environment_id = local.environment_id
  resource_group_name          = local.resource_group
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
        value = "guest"
      }
      env {
        name  = "RABBITMQ_DEFAULT_PASS"
        value = "guest"
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = 15672
    transport        = "http"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

# ==================================================
# Observability: Jaeger, Loki, Grafana
# ==================================================

resource "azurerm_container_app" "jaeger" {
  name                         = "jaeger"
  container_app_environment_id = local.environment_id
  resource_group_name          = local.resource_group
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
    external_enabled = true
    target_port      = 16686
    transport        = "http"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

resource "azurerm_container_app" "loki" {
  name                         = "loki"
  container_app_environment_id = local.environment_id
  resource_group_name          = local.resource_group
  revision_mode                = "Single"

  template {
    min_replicas = 1
    max_replicas = 1

    container {
      name   = "loki"
      image  = "grafana/loki:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  ingress {
    external_enabled = false
    target_port      = 3100
    transport        = "http"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

resource "azurerm_container_app" "grafana" {
  name                         = "grafana"
  container_app_environment_id = local.environment_id
  resource_group_name          = local.resource_group
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
      name   = "grafana"
      image  = "ghcr.io/${var.ghcr_username}/grafana-custom:latest"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "GF_SECURITY_ADMIN_PASSWORD"
        value = "admin"
      }
      env {
        name  = "GF_USERS_ALLOW_SIGN_UP"
        value = "false"
      }
      env {
        name  = "LOKI_URL"
        value = "http://loki:3100"
      }
      env {
        name  = "JAEGER_URL"
        value = "http://jaeger:16686"
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = 3000
    transport        = "http"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

# ==================================================
# APIs: Identity, Catalog, Payment, Gateway, Functions
# ==================================================

resource "azurerm_container_app" "identity_api" {
  name                         = "identity-api"
  container_app_environment_id = local.environment_id
  resource_group_name          = local.resource_group
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
      name   = "identity"
      image  = "ghcr.io/fiap-cloud-gaming/identity-api:latest"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "ASPNETCORE_ENVIRONMENT"
        value = "Development"
      }
      env {
        name  = "ConnectionStrings__IdentityDb"
        value = "Host=postgres-identity;Port=5432;Database=identity_db;Username=postgres;Password=postgres"
      }
      env {
        name  = "ConnectionStrings__RabbitMQ"
        value = "amqp://guest:guest@rabbitmq:5672"
      }
      env {
        name  = "JwtSettings__Secret"
        value = "your-super-secret-key-min-32-chars-long-for-development-only"
      }
      env {
        name  = "JwtSettings__Issuer"
        value = "fcg-identity-api"
      }
      env {
        name  = "JwtSettings__Audience"
        value = "fcg-services"
      }
      env {
        name  = "JwtSettings__AccessTokenExpirationMinutes"
        value = "60"
      }
      env {
        name  = "Loki__Uri"
        value = "http://loki:3100"
      }
      env {
        name  = "OTEL_EXPORTER_OTLP_ENDPOINT"
        value = "http://jaeger:4317"
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

resource "azurerm_container_app" "catalog_api" {
  name                         = "catalog-api"
  container_app_environment_id = local.environment_id
  resource_group_name          = local.resource_group
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
      name   = "catalog"
      image  = "ghcr.io/fiap-cloud-gaming/catalog-api:latest"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "ASPNETCORE_ENVIRONMENT"
        value = "Development"
      }
      env {
        name  = "ConnectionStrings__CatalogDB"
        value = "Host=postgres-catalog;Port=5432;Database=catalog_db;Username=postgres;Password=postgres"
      }
      env {
        name  = "ConnectionStrings__MongoDB"
        value = "mongodb://mongo:27017"
      }
      env {
        name  = "ConnectionStrings__Redis"
        value = "redis:6379"
      }
      env {
        name  = "ConnectionStrings__Elasticsearch"
        value = "http://elasticsearch:9200"
      }
      env {
        name  = "MongoDB__DatabaseName"
        value = "CatalogDB"
      }
      env {
        name  = "Elasticsearch__Uri"
        value = "http://elasticsearch:9200"
      }
      env {
        name  = "JwtSettings__Secret"
        value = "your-super-secret-key-min-32-chars-long-for-development-only"
      }
      env {
        name  = "JwtSettings__Issuer"
        value = "fcg-identity-api"
      }
      env {
        name  = "JwtSettings__Audience"
        value = "fcg-services"
      }
      env {
        name  = "ConnectionStrings__RabbitMQ"
        value = "amqp://guest:guest@rabbitmq:5672"
      }
      env {
        name  = "Loki__Uri"
        value = "http://loki:3100"
      }
      env {
        name  = "OTEL_EXPORTER_OTLP_ENDPOINT"
        value = "http://jaeger:4317"
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

resource "azurerm_container_app" "payment_api" {
  name                         = "payment-api"
  container_app_environment_id = local.environment_id
  resource_group_name          = local.resource_group
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
      name   = "payment"
      image  = "ghcr.io/fiap-cloud-gaming/payment-api:latest"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "ASPNETCORE_ENVIRONMENT"
        value = "Development"
      }
      env {
        name  = "ConnectionStrings__PaymentDB"
        value = "Host=postgres-payment;Port=5432;Database=payment_db;Username=postgres;Password=postgres"
      }
      env {
        name  = "Elasticsearch__Uri"
        value = "http://elasticsearch:9200"
      }
      env {
        name  = "JwtSettings__Secret"
        value = "your-super-secret-key-min-32-chars-long-for-development-only"
      }
      env {
        name  = "JwtSettings__Issuer"
        value = "fcg-identity-api"
      }
      env {
        name  = "JwtSettings__Audience"
        value = "fcg-services"
      }
      env {
        name  = "ConnectionStrings__RabbitMQ"
        value = "amqp://guest:guest@rabbitmq:5672"
      }
      env {
        name  = "Loki__Uri"
        value = "http://loki:3100"
      }
      env {
        name  = "OTEL_EXPORTER_OTLP_ENDPOINT"
        value = "http://jaeger:4317"
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

resource "azurerm_container_app" "gateway_api" {
  name                         = "gateway-api"
  container_app_environment_id = local.environment_id
  resource_group_name          = local.resource_group
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
      name   = "gateway"
      image  = "ghcr.io/fiap-cloud-gaming/gateway-api:latest"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "ASPNETCORE_ENVIRONMENT"
        value = "Development"
      }
      env {
        name  = "JwtSettings__Secret"
        value = "your-super-secret-key-min-32-chars-long-for-development-only"
      }
      env {
        name  = "JwtSettings__Issuer"
        value = "fcg-identity-api"
      }
      env {
        name  = "JwtSettings__Audience"
        value = "fcg-services"
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
        value = "http://loki:3100"
      }
      env {
        name  = "OTEL_EXPORTER_OTLP_ENDPOINT"
        value = "http://jaeger:4317"
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

resource "azurerm_container_app" "functions" {
  name                         = "functions"
  container_app_environment_id = local.environment_id
  resource_group_name          = local.resource_group
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
      name   = "functions"
      image  = "ghcr.io/fiap-cloud-gaming/functions:latest"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "AzureWebJobsStorage"
        value = "UseDevelopmentStorage=true"
      }
      env {
        name  = "FUNCTIONS_WORKER_RUNTIME"
        value = "dotnet-isolated"
      }
      env {
        name  = "RabbitMQ"
        value = "amqp://guest:guest@rabbitmq:5672"
      }
    }
  }
}
