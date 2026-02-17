variable "project_name" {
  description = "prefixo para os recursos do projeto"
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

variable "tags" {
  description = "tags para os recursos"
  type    = map(string)
  default = {}
}
