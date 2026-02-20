variable "subscription_id" {
  description = "azure subscription id"
  type        = string
}

variable "project_name" {
  description = "nome do projeto"
  type        = string
  default     = "fcg"
}

variable "location" {
  description = "regiao azure"
  type        = string
  default     = "brazilsouth"
}

variable "environment" {
  description = "nome do ambiente"
  type        = string
  default     = "dev"
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

variable "image_tag" {
  description = "tag das imagens docker dos servicos"
  type        = string
  default     = "latest"
}

variable "postgres_password" {
  description = "senha dos bancos postgresql"
  type        = string
  sensitive   = true
  default     = "postgres"
}

variable "rabbitmq_user" {
  description = "usuario do rabbitmq"
  type        = string
  default     = "guest"
}

variable "rabbitmq_password" {
  description = "senha do rabbitmq"
  type        = string
  sensitive   = true
  default     = "guest"
}

variable "jwt_secret" {
  description = "secret do JWT"
  type        = string
  sensitive   = true
  default     = "your-super-secret-key-min-32-chars-long-for-development-only"
}

variable "tags" {
  description = "tags para os recursos"
  type        = map(string)
  default = {
    Project   = "FIAP Cloud Gaming"
    ManagedBy = "Terraform"
  }
}