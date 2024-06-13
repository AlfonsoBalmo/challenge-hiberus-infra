resource "aws_db_instance" "default" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "hiberus"
  username             = "hiberus"
  password             = "hiberus123456789"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
}

resource "aws_lambda_function" "my_lambda" {
  function_name = "hiberus"

  s3_bucket = "bucket-hiberus"
  s3_key    = "lambda_function_payload.zip"

  handler = "index.handler"
  runtime = "nodejs12.x"

  environment {
    variables = {
      MYSQLDB_HOST     = aws_db_instance.default.address
      MYSQLDB_USER     = "hiberus"
      MYSQLDB_PASSWORD = "hiberus123456789"
      MYSQLDB_NAME     = "hiberusdatabase"
      MYSQLDB_PORT     = "3306"
    }
  }

  role = aws_iam_role.lambda_exec.arn
}
