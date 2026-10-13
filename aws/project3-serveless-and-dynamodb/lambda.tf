# Configuração do lambda

# Para subir o codigo no lambda ele precisa estar em .zip
data "archive_file" "lambda" {
  # Zipando o codigo
  type        = "zip"
  source_file = "${path.module}/lambda/tasks.py"
  output_path = "${path.module}/lambda/tasks.zip"
}

resource "aws_lambda_function" "tasks" {
  function_name = var.lambda_name
  role          = aws_iam_role.lambda.arn

  # Subir os arquivos no lambda
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.12"
  handler = "tasks.lambda_handler"

  timeout     = 10
  memory_size = 128

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.tasks.name
    }
  }

  depends_on = [
    aws_iam_role_policy.lambda,
    aws_cloudwatch_log_group.lambda
  ]
}