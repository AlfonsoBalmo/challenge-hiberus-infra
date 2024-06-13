resource "aws_db_instance" "default" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0.32"
  instance_class       = "db.t3.micro"
  db_name              = var.db_name
  username             = var.db_user
  password             = var.db_password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
}

resource "aws_lambda_function" "docker_deploy_lambda" {
  function_name = "dockerDeployLambda"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  filename      = "lambda_deploy.zip"
  source_code_hash = filebase64sha256("lambda_deploy.zip")

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

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "lambda.amazonaws.com",
        },
        Effect = "Allow",
        Sid = "",
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
