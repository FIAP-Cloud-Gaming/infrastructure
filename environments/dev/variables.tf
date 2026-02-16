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

variable "vm_size" {
  description = "tamanho da vm"
  type        = string
  default     = "Standard_B4ms"
}

variable "vm_zone" {
  description = "zona da vm"
  type        = string
  default     = "1"
}