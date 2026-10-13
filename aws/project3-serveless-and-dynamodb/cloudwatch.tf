# CloudWatch Configuration
# Criar a configuração de log do lambda
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.lambda_name}"
  retention_in_days = 7
}