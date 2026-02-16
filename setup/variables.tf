variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "project_name" {
  description = "Prefixo do projeto"
  type        = string
  default     = "fcg"
}

variable "location" {
  description = "Regiao Azure"
  type        = string
  default     = "brazilsouth"
}
