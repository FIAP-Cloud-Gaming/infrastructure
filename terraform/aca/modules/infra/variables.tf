variable "environment_id" {
  description = "id do container apps environment"
  type        = string
}

variable "resource_group" {
  description = "nome do resource group"
  type        = string
}

variable "postgres_password" {
  description = "senha do postgresql"
  type        = string
  sensitive   = true
}

variable "rabbitmq_user" {
  description = "usuario do rabbitmq"
  type        = string
}

variable "rabbitmq_password" {
  description = "senha do rabbitmq"
  type        = string
  sensitive   = true
}