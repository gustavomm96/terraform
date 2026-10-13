# Configuração do dynamoDB
resource "aws_dynamodb_table" "tasks" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST" # Melhor para free tier
  hash_key     = "task_id"

  attribute {
    name = "task_id"
    type = "S"
  }
  
  # Configuração adequada para ambientes de pd para o dynamo
  # point_in_time_recovery {
  #   enabled = true
  # }

  # lifecycle {
  #   prevent_destroy = true
  # }

  tags = merge(local.common_tags, {
    Name = var.table_name
  })
}