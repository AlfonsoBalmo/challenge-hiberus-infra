provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main" {
  count = 2
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group" "lambda_sg" {
  name_prefix = "lambda_sg_"
  vpc_id = aws_vpc.main.id

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

resource "aws_db_instance" "default" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  db_name              = var.db_name
  username             = var.db_user
  password             = var.db_password
  parameter_group_name = "default.mysql5.7"
  vpc_security_group_ids = [aws_security_group.lambda_sg.id]
  skip_final_snapshot  = true
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_exec_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "docker_deploy_lambda" {
  filename         = "${path.module}/lambda_deploy.zip"
  function_name    = "docker_deploy_lambda"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"

  environment {
    variables = {
      MYSQLDB_HOST     = aws_db_instance.default.endpoint
      MYSQLDB_USER     = var.db_user
      MYSQLDB_PASSWORD = var.db_password
      MYSQLDB_NAME     = var.db_name
      MYSQLDB_PORT     = "3306"
    }
  }
}
