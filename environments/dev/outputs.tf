output "public_ip" {
  description = "IP publico da VM"
  value       = module.networking.public_ip_address
}

output "ssh_command" {
  description = "Comando para conectar via SSH"
  value       = "ssh ${module.vm.admin_username}@${module.networking.public_ip_address}"
}

output "gateway_url" {
  description = "URL do Gateway API"
  value       = "http://${module.networking.public_ip_address}:5000"
}

output "rabbitmq_url" {
  description = "URL do RabbitMQ Management"
  value       = "http://${module.networking.public_ip_address}:15672"
}

output "grafana_url" {
  description = "URL do Grafana"
  value       = "http://${module.networking.public_ip_address}:3000"
}

output "jaeger_url" {
  description = "URL do Jaeger"
  value       = "http://${module.networking.public_ip_address}:16686"
}

output "kibana_url" {
  description = "URL do Kibana"
  value       = "http://${module.networking.public_ip_address}:5601"
}