variable "db_identifier" {
  description = "The DB instance identifier"
  type        = string
  default     = "myapp-db"
}

variable "db_name" {
  description = "The name of the database to create"
  type        = string
  default     = "challenge-hiberus"
}

variable "db_username" {
  description = "The username for the database"
  type        = string
  default     = "hiberus"
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  default     = "123456789hiberus"
}
