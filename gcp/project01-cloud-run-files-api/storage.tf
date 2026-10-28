# Criar storage 
resource "google_storage_bucket" "files" {
  name                        = "${var.project_id}-files-api"
  location                    = "US-CENTRAL1"
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = true # Permite deletar a storage mesmo com objetos dentro

  # Life cycle com regra apenas para deletar
  lifecycle_rule {
    action {
      type = "Delete"
    }

    condition {
      age = 7
    }
  }

  depends_on = [
    google_project_service.required["storage.googleapis.com"]
  ]
}