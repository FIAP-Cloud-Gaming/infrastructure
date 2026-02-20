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

variable "node_count" {
  description = "numero inicial de nodes no pool"
  type        = number
  default     = 2
}

variable "node_min_count" {
  description = "minimo de nodes (auto-scale)"
  type        = number
  default     = 1
}

variable "node_max_count" {
  description = "maximo de nodes (auto-scale)"
  type        = number
  default     = 3
}

variable "node_size" {
  description = "tamanho da VM dos nodes"
  type        = string
  default     = "Standard_B4ms"
}

variable "kubernetes_version" {
  description = "versao do kubernetes"
  type        = string
  default     = "1.33"
}

variable "ghcr_token" {
  description = "pat token para autenticacao no ghcr"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "tags para os recursos"
  type        = map(string)
  default = {
    Project   = "FIAP Cloud Gaming"
    ManagedBy = "Terraform"
  }
}
