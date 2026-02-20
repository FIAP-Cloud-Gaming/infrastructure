variable "environment_id" {
  description = "id do container apps environment"
  type        = string
}

variable "resource_group" {
  description = "nome do resource group"
  type        = string
}

variable "ghcr_username" {
  description = "username do ghcr"
  type        = string
}

variable "ghcr_token" {
  description = "token do ghcr"
  type        = string
  sensitive   = true
}