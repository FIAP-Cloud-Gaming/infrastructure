output "postgres_name" {
  value = azurerm_container_app.postgres.name
}

output "mongo_name" {
  value = azurerm_container_app.mongo.name
}

output "redis_name" {
  value = azurerm_container_app.redis.name
}

output "elasticsearch_name" {
  value = azurerm_container_app.elasticsearch.name
}

output "rabbitmq_name" {
  value = azurerm_container_app.rabbitmq.name
}