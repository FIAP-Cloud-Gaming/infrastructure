module "resource_group" {
  source       = "../../modules/resource-group"
  project_name = var.project_name
  location     = var.location
  environment  = var.environment
  tags         = merge(
    var.tags,
    {
      Environment = var.environment
    }
  )
}

module "networking" {
  source              = "../../modules/networking"
  project_name        = var.project_name
  resource_group_name = module.resource_group.name
  location            = var.location
  environment         = var.environment
  open_ports          = [443, 80]
  tags                = var.tags
}

module "container_apps" {
  source                   = "../../modules/container-apps"
  project_name             = var.project_name
  resource_group_name      = module.resource_group.name
  location                 = var.location
  infrastructure_subnet_id = module.networking.subnet_id
  tags                     = merge(
    var.tags,
    {
      Environment = var.environment
    }
  )
}

locals {
  location         = module.resource_group.location
  environment_id   = module.container_apps.environment_id
  resource_group   = module.resource_group.name
  ghcr_secret_name = "ghcr-token"
}

# ==================================================
# Infrastructure: PostgreSQL
# ==================================================

resource "azurerm_postgresql_flexible_server" "postgres" {
  name                = "${var.project_name}-postgres"
  resource_group_name = local.resource_group
  location            = local.location

  version = "15"

  administrator_login    = "pgadmin"
  administrator_password = var.postgres_password

  sku_name   = "B_Standard_B1ms"
  storage_mb = 32768

  backup_retention_days = 7

  delegated_subnet_id = module.networking.postgres_subnet_id
  private_dns_zone_id = module.networking.private_dns_zone_id

  public_network_access_enabled = false
}

resource "azurerm_postgresql_flexible_server_database" "identity" {
  name      = "identity_db"
  server_id = azurerm_postgresql_flexible_server.postgres.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

resource "azurerm_postgresql_flexible_server_database" "catalog" {
  name      = "catalog_db"
  server_id = azurerm_postgresql_flexible_server.postgres.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

resource "azurerm_postgresql_flexible_server_database" "payment" {
  name      = "payment_db"
  server_id = azurerm_postgresql_flexible_server.postgres.id
  charset   = "UTF8"
  collation = "en_US.utf8"
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
    min_replicas = 0
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
    min_replicas = 0
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
    min_replicas = 0
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
    min_replicas = 0
    max_replicas = 1

    container {
      name   = "rabbitmq"
      image  = "rabbitmq:4.1-management-alpine"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "RABBITMQ_DEFAULT_USER"
        value = "admin"
      }
      env {
        name  = "RABBITMQ_DEFAULT_PASS"
        value = var.rabbitmq_password
      }
    }
  }

  ingress {
    external_enabled = false
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
    min_replicas = 0
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
    min_replicas = 0
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
    min_replicas = 0
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
    external_enabled = false
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
    min_replicas = 0
    max_replicas = 1

    container {
      name   = "identity"
      image  = "ghcr.io/fiap-cloud-gaming/identity-api:latest"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "ASPNETCORE_ENVIRONMENT"
        value = "Production"
      }
      env {
        name  = "ConnectionStrings__IdentityDb"
        value = "Host=${azurerm_postgresql_flexible_server.postgres.fqdn};Ssl Mode=Require;Database=identity_db;Username=pgadmin;Password=${var.postgres_password}"
      }
      env {
        name  = "ConnectionStrings__RabbitMQ"
        value = "amqp://admin:${var.rabbitmq_password}@rabbitmq:5672"
      }
      env {
        name  = "JwtSettings__Secret"
        value = var.jwt_secret
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
    min_replicas = 0
    max_replicas = 1

    container {
      name   = "catalog"
      image  = "ghcr.io/fiap-cloud-gaming/catalog-api:latest"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "ASPNETCORE_ENVIRONMENT"
        value = "Production"
      }
      env {
        name  = "ConnectionStrings__CatalogDB"
        value = "Host=${azurerm_postgresql_flexible_server.postgres.fqdn};Ssl Mode=Require;Database=catalog_db;Username=pgadmin;Password=${var.postgres_password}"
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
        value = var.jwt_secret
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
        value = "amqp://admin:${var.rabbitmq_password}@rabbitmq:5672"
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
    min_replicas = 0
    max_replicas = 1

    container {
      name   = "payment"
      image  = "ghcr.io/fiap-cloud-gaming/payment-api:latest"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "ASPNETCORE_ENVIRONMENT"
        value = "Production"
      }
      env {
        name  = "ConnectionStrings__PaymentDB"
        value = "Host=${azurerm_postgresql_flexible_server.postgres.fqdn};Ssl Mode=Require;Database=payment_db;Username=pgadmin;Password=${var.postgres_password}"
      }
      env {
        name  = "Elasticsearch__Uri"
        value = "http://elasticsearch:9200"
      }
      env {
        name  = "JwtSettings__Secret"
        value = var.jwt_secret
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
        value = "amqp://admin:${var.rabbitmq_password}@rabbitmq:5672"
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
    min_replicas = 0
    max_replicas = 1

    container {
      name   = "gateway"
      image  = "ghcr.io/fiap-cloud-gaming/gateway-api:latest"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "ASPNETCORE_ENVIRONMENT"
        value = "Production"
      }
      env {
        name  = "JwtSettings__Secret"
        value = var.jwt_secret
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
    min_replicas = 0
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
        value = "amqp://admin:${var.rabbitmq_password}@rabbitmq:5672"
      }
    }
  }
}
