output "db_endpoint" {
  value = aws_db_instance.default.endpoint
}

output "lambda_arn" {
  value = aws_lambda_function.docker_deploy_lambda.arn
}
