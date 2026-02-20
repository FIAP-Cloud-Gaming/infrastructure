resource "azurerm_container_app" "functions" {
  name                         = "functions"
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
      name   = "functions"
      image  = "ghcr.io/fiap-cloud-gaming/functions:${var.image_tag}"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "AzureWebJobsStorage"
        value = "DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://azurite:10000/devstoreaccount1;QueueEndpoint=http://azurite:10001/devstoreaccount1;TableEndpoint=http://azurite:10002/devstoreaccount1;"
      }
      env {
        name  = "FUNCTIONS_WORKER_RUNTIME"
        value = "dotnet-isolated"
      }
      env {
        name  = "RabbitMQ"
        value = "amqp://${var.rabbitmq_user}:${var.rabbitmq_password}@rabbitmq:5672"
      }
    }
  }
}