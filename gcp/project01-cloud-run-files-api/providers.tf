provider "google" {
  project = var.project_id
  region  = var.region

  #Labels são as tags do recurso, que podem ser usadas para identificar e organizar recursos no GCP.
  default_labels = {
    project     = "gcp-cloud-run-files-api"
    environment = "dev"
    managed_by  = "terraform"
    owner       = "gustavo"
  }
}