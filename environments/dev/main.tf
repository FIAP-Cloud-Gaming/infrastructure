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
    min_replicas = 0
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
    external_enabled = var.resource_ingress_config["postgres_identity"].external_enabled
    target_port      = var.resource_ingress_config["postgres_identity"].port
    transport        = var.resource_ingress_config["postgres_identity"].transport

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
    external_enabled = var.resource_ingress_config["postgres_catalog"].external_enabled
    target_port      = var.resource_ingress_config["postgres_catalog"].port
    transport        = var.resource_ingress_config["postgres_catalog"].transport

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
    min_replicas = 0
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
    external_enabled = var.resource_ingress_config["postgres_payment"].external_enabled
    target_port      = var.resource_ingress_config["postgres_payment"].port
    transport        = var.resource_ingress_config["postgres_payment"].transport

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
    external_enabled = var.resource_ingress_config["mongo"].external_enabled
    target_port      = var.resource_ingress_config["mongo"].port
    transport        = var.resource_ingress_config["mongo"].transport

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
    external_enabled = var.resource_ingress_config["redis"].external_enabled
    target_port      = var.resource_ingress_config["redis"].port
    transport        = var.resource_ingress_config["redis"].transport

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
    external_enabled = var.resource_ports[5].external_enabled
    target_port      = var.resource_ports[5].port
    transport        = var.resource_ports[5].transport

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
    external_enabled = var.resource_ingress_config["rabbitmq"].external_enabled
    target_port      = var.resource_ingress_config["rabbitmq"].port
    transport        = var.resource_ingress_config["rabbitmq"].transport
    exposed_port     = var.resource_ingress_config["rabbitmq"].port

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
    external_enabled = var.resource_ingress_config["jaeger"].external_enabled
    target_port      = var.resource_ingress_config["jaeger"].port
    transport        = var.resource_ingress_config["jaeger"].transport

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
    external_enabled = var.resource_ingress_config["loki"].external_enabled
    target_port      = var.resource_ingress_config["loki"].port
    transport        = var.resource_ingress_config["loki"].transport

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
        value = "http://loki:${var.resource_ingress_config["loki"].port}"
      }
      env {
        name  = "JAEGER_URL"
        value = "http://jaeger:${var.resource_ingress_config["jaeger"].port}"
      }
    }
  }

  ingress {
    external_enabled = var.resource_ingress_config["grafana"].external_enabled
    target_port      = var.resource_ingress_config["grafana"].port
    transport        = var.resource_ingress_config["grafana"].transport

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
        value = "Host=postgres-identity;Port=${var.resource_ingress_config["postgres_identity"].port};Database=identity_db;Username=postgres;Password=postgres"
      }
      env {
        name  = "ConnectionStrings__RabbitMQ"
        value = "amqp://guest:guest@rabbitmq:${var.resource_ingress_config["rabbitmq"].port}"
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
        value = "http://loki:${var.resource_ingress_config["loki"].port}"
      }
      env {
        name  = "OTEL_EXPORTER_OTLP_ENDPOINT"
        value = "http://jaeger:${var.resource_ingress_config["jaeger"].port}"
      }
    }
  }

  ingress {
    external_enabled = var.resource_ingress_config["identity_api"].external_enabled
    target_port      = var.resource_ingress_config["identity_api"].port
    transport        = var.resource_ingress_config["identity_api"].transport

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
        value = "Host=postgres-catalog;Port=${var.resource_ingress_config["postgres_catalog"].port};Database=catalog_db;Username=postgres;Password=postgres"
      }
      env {
        name  = "ConnectionStrings__MongoDB"
        value = "mongodb://mongo:${var.resource_ingress_config["mongo"].port}"
      }
      env {
        name  = "ConnectionStrings__Redis"
        value = "redis:${var.resource_ingress_config["redis"].port}"
      }
      env {
        name  = "ConnectionStrings__Elasticsearch"
        value = "http://elasticsearch:${var.resource_ingress_config["elasticsearch"].port}"
      }
      env {
        name  = "MongoDB__DatabaseName"
        value = "CatalogDB"
      }
      env {
        name  = "Elasticsearch__Uri"
        value = "http://elasticsearch:${var.resource_ingress_config["elasticsearch"].port}"
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
        value = "amqp://guest:guest@rabbitmq:${var.resource_ingress_config["rabbitmq"].port}"
      }
      env {
        name  = "Loki__Uri"
        value = "http://loki:${var.resource_ingress_config["loki"].port}"
      }
      env {
        name  = "OTEL_EXPORTER_OTLP_ENDPOINT"
        value = "http://jaeger:${var.resource_ingress_config["jaeger"].port}"
      }
    }
  }

  ingress {
    external_enabled = var.resource_ingress_config["gateway_api"].external_enabled
    target_port      = var.resource_ingress_config["gateway_api"].port
    transport        = var.resource_ingress_config["gateway_api"].transport

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
        value = "Host=postgres-payment;Port=${var.resource_ingress_config["postgres_payment"].port};Database=payment_db;Username=postgres;Password=postgres"
      }
      env {
        name  = "Elasticsearch__Uri"
        value = "http://elasticsearch:${var.resource_ingress_config["elasticsearch"].port}"
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
        value = "amqp://guest:guest@rabbitmq:${var.resource_ingress_config["rabbitmq"].port}"
      }
      env {
        name  = "Loki__Uri"
        value = "http://loki:${var.resource_ingress_config["loki"].port}"
      }
      env {
        name  = "OTEL_EXPORTER_OTLP_ENDPOINT"
        value = "http://jaeger:${var.resource_ingress_config["jaeger"].port}"
      }
    }
  }

  ingress {
    external_enabled = var.resource_ingress_config["payment_api"].external_enabled
    target_port      = var.resource_ingress_config["payment_api"].port
    transport        = var.resource_ingress_config["payment_api"].transport

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
        value = "http://loki:${var.resource_ingress_config["loki"].port}"
      }
      env {
        name  = "OTEL_EXPORTER_OTLP_ENDPOINT"
        value = "http://jaeger:${var.resource_ingress_config["jaeger"].port}"
      }
    }
  }

  ingress {
    external_enabled = var.resource_ingress_config["gateway_api"].external_enabled
    target_port      = var.resource_ingress_config["gateway_api"].port
    transport        = var.resource_ingress_config["gateway_api"].transport

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
        value = "amqp://guest:guest@rabbitmq:${var.resource_ingress_config["rabbitmq"].port}"
      }
    }
  }
}
