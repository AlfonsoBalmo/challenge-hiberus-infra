output "db_endpoint" {
  value = aws_db_instance.default.endpoint
}

output "ecs_service_name" {
  value = aws_ecs_service.app.name
}

output "ecs_task_definition" {
  value = aws_ecs_task_definition.app.family
}
