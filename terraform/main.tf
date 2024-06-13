provider "aws" {
  region = "us-east-1"
}

resource "aws_db_instance" "mysql" {
  identifier         = var.db_identifier
  allocated_storage  = 20
  storage_type       = "gp2"
  engine             = "mysql"
  engine_version     = "5.7"
  instance_class     = "db.t2.micro"
  db_name            = var.db_name
  username           = var.db_username
  password           = var.db_password
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot = true
  publicly_accessible = true
  vpc_security_group_ids = [var.existing_security_group_id]
  db_subnet_group_name = var.existing_db_subnet_group_name

  tags = {
    Name = "hiberus-mysql"
  }
}
