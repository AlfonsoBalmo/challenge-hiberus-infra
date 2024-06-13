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

output "vpc_id" {
  description = "The VPC ID"
  value       = aws_vpc.main.id
}

output "subnet_ids" {
  description = "The IDs of the subnets"
  value       = aws_subnet.public[*].id
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.db_sg.id
}
