variable "subscription_id" {
  description = "azure subscription id"
  type        = string
}

variable "project_name" {
  description = "prefixo para os recursos"
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

variable "vm_size" {
  description = "tamanho da vm"
  type        = string
  default     = "Standard_B4ms"
}

variable "admin_username" {
  description = "usuario ssh da vm"
  type        = string
  default     = "azureuser"
}

variable "ghcr_username" {
  description = "username do ghcr"
  type        = string
}

variable "ghcr_token" {
  description = "pat token para autenticacao no ghcr"
  type        = string
  sensitive   = true
}

variable "image_tag" {
  description = "tag das imagens docker"
  type        = string
  default     = "latest"
}

variable "postgres_password" {
  description = "senha do postgresql"
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
  description = "chave secreta para jwt"
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