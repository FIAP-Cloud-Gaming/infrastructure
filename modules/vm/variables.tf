variable "project_name" {
  description = "nome do projeto"
  type        = string
}

variable "resource_group_name" {
  description = "nome do rg"
  type        = string
}

variable "location" {
  description = "regiao azure"
  type        = string
}

variable "subnet_id" {
  description = "id do subnet"
  type        = string
}

variable "public_ip_id" {
  description = "id do ip publico"
  type        = string
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

variable "admin_username" {
  description = "usuario ssh da vm"
  type        = string
  default     = "azureuser"
}

variable "os_disk_size_gb" {
  description = "tamanho do disco os"
  type        = number
  default     = 64
}