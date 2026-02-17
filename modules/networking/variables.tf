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

variable "environment" {
  description = "nome do ambiente (dev, prod)"
  type        = string
}

variable "open_ports" {
  description = "portas liberadas no NSG (inbound)"
  type        = list(number)
  default     = [443, 80]
}

variable "tags" {
  description = "tags para os recursos"
  type    = map(string)
  default = {}
}
