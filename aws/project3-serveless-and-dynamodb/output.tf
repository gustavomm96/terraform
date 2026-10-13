output "api_endpoint" {
  description = "Endpoint público da API."
  value       = aws_apigatewayv2_stage.default.invoke_url
}

output "dynamodb_table_name" {
  description = "Nome da tabela DynamoDB."
  value       = aws_dynamodb_table.tasks.name
}

output "lambda_function_name" {
  description = "Nome da função Lambda."
  value       = aws_lambda_function.tasks.function_name
}