variable "aws_region" {
  description = "The AWS region to create resources in"
  type        = string
  default     = "us-east-1"
}

variable "db_name" {
  description = "The name of the database"
  type        = string
  default     = "challengehiberus"
}

variable "db_user" {
  description = "The database admin user"
  type        = string
  default     = "hiberus"
}

variable "db_password" {
  description = "The database admin password"
  type        = string
  default     = "123456789hiberus"
}

variable "ecr_repository_url" {
  description = "The URL of the ECR repository"
  type        = string
}
