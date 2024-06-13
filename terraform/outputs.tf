output "db_endpoint" {
  value = aws_db_instance.default.endpoint
}

output "ecs_service_name" {
  value = aws_ecs_service.app.name
}

output "ecs_task_definition" {
  value = aws_ecs_task_definition.app.family
}

output "ecr_repository_url" {
  value = aws_ecr_repository.myapp.repository_url
}

output "alb_dns" {
  value = aws_lb.app.dns_name
}
