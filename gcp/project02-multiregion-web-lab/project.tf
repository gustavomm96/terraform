# Criar o projeto onde vai ficar a infraestrutura

resource "random_id" "project_suffix" {
  byte_length = 3
}

# é necessário cria project id unico, porque o GCP não permite reutilizar o Project ID de um projeto excluído
resource "google_project" "lab" {
  name            = var.project_name
  project_id      = "${var.project_id_prefix}-${random_id.project_suffix.hex}"
  billing_account = var.billing_account_id
  org_id          = var.org_id

  deletion_policy = "DELETE"
}