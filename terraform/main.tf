provider "aws" {
  region = "us-east-1"
}

variable "existing_vpc_id" {
  description = "The ID of an existing VPC"
  type        = string
}

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = var.existing_vpc_id
  cidr_block              = cidrsubnet("10.0.0.0/16", 8, count.index)
  availability_zone       = element(["us-east-1a", "us-east-1b"], count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index}"
  }
}

resource "aws_security_group" "db_sg" {
  name        = "db_sg"
  description = "Allow MySQL inbound traffic"
  vpc_id      = var.existing_vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "main-${random_id.db_subnet_group.hex}"
  subnet_ids = aws_subnet.public[*].id

  tags = {
    Name = "main-${random_id.db_subnet_group.hex}"
  }
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
  db_subnet_group_name = aws_db_subnet_group.main.name
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot = true
  publicly_accessible = true
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  tags = {
    Name = "hiberus-mysql"
  }
}

resource "random_id" "db_subnet_group" {
  byte_length = 4
}
