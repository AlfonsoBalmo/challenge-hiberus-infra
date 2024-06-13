output "db_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.mysql.endpoint
}

output "db_username" {
  description = "The username for the database"
  value       = var.db_username
}

output "db_name" {
  description = "The name of the database"
  value       = var.db_name
}
