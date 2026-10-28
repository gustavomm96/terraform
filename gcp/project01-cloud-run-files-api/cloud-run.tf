# Cloud run configuration

resource "google_cloud_run_v2_service" "files_api" {
  name     = "gcp-files-api"
  location = var.region

  invoker_iam_disabled = true

  template {
    service_account = google_service_account.cloud_run.email
    # Aponta para imagem do registry que eu subi
    containers {
      image = "us-central1-docker.pkg.dev/${var.project_id}/files-api/gcp-files-api:1.0.0"

      ports {
        container_port = 8080
      }

      env {
        name  = "GOOGLE_CLOUD_PROJECT"
        value = var.project_id
      }

      env {
        name  = "BUCKET_NAME"
        value = google_storage_bucket.files.name
      }
      # Recursos do pod
      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }
    }
    # Configuração do horizontal scale
    scaling {
      min_instance_count = 0
      max_instance_count = 1
    }
  }
  deletion_protection = false # Permite dar destroy via terraform

  depends_on = [
    google_project_service.required["run.googleapis.com"],
    google_project_service.required["artifactregistry.googleapis.com"],
    google_storage_bucket_iam_member.files_object_viewer,
    google_storage_bucket_iam_member.files_object_creator
  ]
}