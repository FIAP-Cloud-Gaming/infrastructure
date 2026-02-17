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
  description = "username para autenticacao no GitHub Container Registry"
  type        = string
}

variable "ghcr_token" {
  description = "PAT token para autenticacao no GitHub Container Registry"
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
