variable "subscription_id" {
  description = "azure subscription id"
  type        = string
}

variable "project_name" {
  description = "nome do projeto"
  type        = string
  default     = "fcg-prod"
}

variable "location" {
  description = "regiao azure"
  type        = string
  default     = "brazilsouth"
}

variable "environment" {
  description = "nome do ambiente"
  type        = string
  default     = "prod"
}

variable "ghcr_username" {
  description = "username para autenticacao no ghcr"
  type        = string
}

variable "ghcr_token" {
  description = "pat token para autenticacao no ghcr"
  type        = string
  sensitive   = true
}


variable "postgres_password" {
  description = "senha dos bancos postgresql"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "secret do JWT"
  type        = string
  sensitive   = true
}

variable "rabbitmq_password" {
  description = "senha do rabbitmq"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "tags para os recursos"
  type        = map(string)
  default = {
    Project   = "FIAP Cloud Gaming"
    ManagedBy = "Alessandro.DEV"
  }
}

variable "resource_ingress_config" {
  description = "Portas dos recursos do ambiente"

  type = map(object({
    port             = number
    external_enabled = bool
    transport        = string
  }))

  default = {
    postgres_identity = { port = 5432,  external_enabled = false, transport = "tcp" }
    postgres_catalog  = { port = 5432,  external_enabled = false, transport = "tcp" }
    postgres_payment  = { port = 5432,  external_enabled = false, transport = "tcp" }
    mongo             = { port = 27017, external_enabled = false, transport = "tcp" }
    redis             = { port = 6379,  external_enabled = false, transport = "tcp" }
    elasticsearch     = { port = 9200,  external_enabled = false, transport = "tcp" }
    rabbitmq          = { port = 5672,  external_enabled = false, transport = "tcp" }
    jaeger            = { port = 16686, external_enabled = true,  transport = "http" }
    loki              = { port = 3100,  external_enabled = true,  transport = "http" }
    grafana           = { port = 3000,  external_enabled = true,  transport = "http" }
    identity_api      = { port = 8080,  external_enabled = false, transport = "http" }
    catalog_api       = { port = 8080,  external_enabled = false, transport = "http" }
    payment_api       = { port = 8080,  external_enabled = false, transport = "http" }
    gateway_api       = { port = 8080,  external_enabled = true,  transport = "http" }
  }
}
