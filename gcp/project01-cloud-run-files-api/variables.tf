variable "project_id" {
  description = "Google Cloud Project ID onde os recursos serão criados."
  type        = string
}

variable "region" {
  description = "Região padrão para recursos regionais do projeto."
  type        = string
  default     = "us-central1"
}