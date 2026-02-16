variable "project_name" {
  description = "prefixo para os recursos do projeto"
  type        = string
  default     = "fcg"
}

variable "location" {
  description = "regiao Azure"
  type        = string
  default     = "brazilsouth"
}

variable "open_ports" {
  description = "portas do firewall"
  type        = list(object({
    name     = string
    port     = number
    priority = number
  }))
  default = [
    { name = "ssh",           port = 22,    priority = 100 },
    { name = "gateway",       port = 5000,  priority = 200 },
    { name = "identity",      port = 5001,  priority = 201 },
    { name = "catalog",       port = 5002,  priority = 202 },
    { name = "payment",       port = 5003,  priority = 203 },
    { name = "rabbitmq-ui",   port = 15672, priority = 300 },
    { name = "elasticsearch", port = 9200,  priority = 301 },
    { name = "kibana",        port = 5601,  priority = 302 },
    { name = "jaeger",        port = 16686, priority = 303 },
    { name = "grafana",       port = 3000,  priority = 304 },
  ]
}