# Habilitar APIs
# No GCP, muitos serviços só podem ser usados depois que sua API correspondente está habilitada no projeto

locals {
  required_apis = toset([
    "artifactregistry.googleapis.com", # Criar o repositório onde ficará a imagem Docker
    "cloudbuild.googleapis.com",       # Fazer build da imagem no GCP com gcloud builds submit
    "iam.googleapis.com",              # Criar a service account e aplicar permissões IAM
    "run.googleapis.com",              # Criar e executar o serviço Cloud Run
    "storage.googleapis.com"           # Criar o bucket e permitir operações com arquivos
  ])
}

# Após habilitar, comando para ver as APIs ativas
# gcloud services list --enabled
resource "google_project_service" "required" {
  for_each = local.required_apis

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false # Quando aplicar terraform destroy as APIs hablitadas não vão ser desabilitadas
}