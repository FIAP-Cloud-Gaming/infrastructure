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
