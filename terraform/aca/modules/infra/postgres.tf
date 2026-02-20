resource "azurerm_container_app" "postgres" {
  name                         = "postgres"
  container_app_environment_id = var.environment_id
  resource_group_name          = var.resource_group
  revision_mode                = "Single"

  template {
    min_replicas = 1
    max_replicas = 1

    container {
      name   = "postgres"
      image  = "postgres:18.1-alpine"
      cpu    = 0.5
      memory = "1Gi"

      command = [
        "/bin/sh", "-c",
        "echo 'CREATE DATABASE identity_db; CREATE DATABASE catalog_db; CREATE DATABASE payment_db;' > /docker-entrypoint-initdb.d/create-dbs.sql && exec docker-entrypoint.sh postgres"
      ]

      env {
        name  = "POSTGRES_USER"
        value = "postgres"
      }
      env {
        name  = "POSTGRES_PASSWORD"
        value = var.postgres_password
      }
    }
  }

  ingress {
    external_enabled = false
    target_port      = 5432
    transport        = "tcp"
    exposed_port     = 5432

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}
