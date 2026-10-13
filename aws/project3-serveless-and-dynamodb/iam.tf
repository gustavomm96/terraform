# Configuração do role e da policy

# Obeter informação do meu usuario
data "aws_region" "current" {}

resource "aws_iam_role" "lambda" {
  name = "gm-lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "lambda.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Criar a policy para ler e inserir, vai ser atribuida no lambda e com isso vai permitir que o lambda o processo de obter e inserir dados
resource "aws_iam_role_policy" "lambda" {
  name = "gm-lambda-policy"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]

        Resource = aws_dynamodb_table.tasks.arn
      }, # e configuração para permitir inserir logs no cloud watch
      {
        Effect = "Allow"

        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]

        #Resource = "arn:aws:logs:${data.aws_region.current.name}:*:log-group:/aws/lambda/*" #deprecated
        Resource = "arn:aws:logs:${data.aws_region.current.region}:*:log-group:/aws/lambda/*"
      }
    ]
  })
}
