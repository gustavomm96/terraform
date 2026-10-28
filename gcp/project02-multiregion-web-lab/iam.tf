# Criar service account - representa a identidade do workload
resource "google_service_account" "web_servers" {
  project = google_project.lab.project_id

  account_id   = "web-servers"
  display_name = "Web Servers Service Account"
  description  = "Dedicated runtime identity for the videos and images web servers."

  depends_on = [
    google_project_service.required["iam.googleapis.com"]
  ]
}