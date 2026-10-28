# registro privado de imagens Docker

# gcloud artifacts repositories list --location us-central1
resource "google_artifact_registry_repository" "files_api" {
  location      = var.region
  repository_id = "files-api"
  description   = "Docker images for the GCP Cloud Run Files API"
  format        = "DOCKER"

  # Em PD é o ideal ter essa configuração, porque força mudar a tag ao fazer deploy da imagem, com isso,
  # Sempre que tiver uma versão nova vai ter que alteara a tag da versão
  #   docker_config {
  #   immutable_tags = true  # impede sobrescrever tags como 1.0.0
  #   }

  # Depende que a API esteja ativa
  depends_on = [
    google_project_service.required["artifactregistry.googleapis.com"]
  ]
}