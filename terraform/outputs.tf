output "db_endpoint" {
  value = aws_db_instance.default.endpoint
}

output "lambda_function_name" {
  value = aws_lambda_function.docker_deploy_lambda.function_name
}
