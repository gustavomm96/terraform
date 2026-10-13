resource "aws_apigatewayv2_api" "tasks" {
  name          = var.api_name
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"] # Aqui seria o ideal a URL da aplicação que vai chamar a api
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["content-type"]
  }
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id = aws_apigatewayv2_api.tasks.id

  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.tasks.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_tasks" {
  api_id    = aws_apigatewayv2_api.tasks.id
  route_key = "GET /tasks"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_route" "post_tasks" {
  api_id    = aws_apigatewayv2_api.tasks.id
  route_key = "POST /tasks"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.tasks.id
  name        = "$default"
  auto_deploy = true
}

# Permissão para a API invocar o lambda
# Sem essa permissão, o API Gateway poderá existir, mas receberá erro ao tentar invocar a função. 
# API Gateway funciona como a porta de entrada e encaminha métodos/rotas para a Lambda.
resource "aws_lambda_permission" "api_gateway" {
  statement_id = "AllowApiGatewayInvoke"
  action       = "lambda:InvokeFunction"

  function_name = aws_lambda_function.tasks.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.tasks.execution_arn}/*/*"
}