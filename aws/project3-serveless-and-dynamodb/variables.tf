variable "table_name" {
  description = "Nome da tabela DynamoDB."
  type        = string
  default     = "gm-tasks"
}

variable "lambda_name" {
  description = "Nome da função Lambda."
  type        = string
  default     = "lambda-gm-tasks-function"
}

variable "api_name" {
  description = "Nome da API HTTP."
  type        = string
  default     = "gm-tasks-api"
}