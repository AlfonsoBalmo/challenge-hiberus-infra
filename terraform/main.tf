provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone       = element(["us-east-1a", "us-east-1b"], count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index}"
  }
}

resource "aws_security_group" "db_sg" {
  name        = "db_sg"
  description = "Allow MySQL inbound traffic"
  vpc_id      = aws_vpc.main.id

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
  name       = "main"
  subnet_ids = aws_subnet.public[*].id

  tags = {
    Name = "main"
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
