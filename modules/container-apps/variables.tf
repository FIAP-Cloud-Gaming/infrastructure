variable "project_name" {
  description = "prefixo para os recursos"
  type        = string
}

variable "resource_group_name" {
  description = "nome do resource group"
  type        = string
}

variable "location" {
  description = "regiao azure"
  type        = string
}

variable "infrastructure_subnet_id" {
  description = "ID da subnet para integrar o Container Apps Environment com VNet (null = rede gerenciada)"
  type        = string
  default     = null
}

variable "tags" {
  description = "tags para os recursos"
  type    = map(string)
  default = {}
}
