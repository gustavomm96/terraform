# Service account do administration vm
resource "google_service_account" "administration" {
  project = google_project.lab.project_id

  account_id   = "administration-vm"
  display_name = "Administration VM Service Account"
  description  = "Dedicated runtime identity for the administrative Windows VM."

  depends_on = [
    google_project_service.required["iam.googleapis.com"],
  ]
}

# Permissão para escrever logs
resource "google_project_iam_member" "administration_log_writer" {
  project = google_project.lab.project_id

  role = "roles/logging.logWriter"

  member = "serviceAccount:${google_service_account.administration.email}"

  depends_on = [
    google_project_service.required["logging.googleapis.com"]
  ]
}