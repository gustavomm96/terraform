# Dar permissão para a API chegar na storage

resource "google_service_account" "cloud_run" {
  account_id   = "files-api-runner"
  display_name = "Cloud Run Files API Service Account"
  description  = "Identity used by the Cloud Run Files API to access Cloud Storage."

  depends_on = [
    google_project_service.required["iam.googleapis.com"]
  ]
}

# google_storage_bucket_iam_member = não autoritativo: ele acrescenta uma permissão para uma identidade sem substituir a policy inteira do bucket
# NÂO Misture google_storage_bucket_iam_policy com google_storage_bucket_iam_member para o mesmo bucket, pois eles entram em conflito.
# Permissão para ler objetos
resource "google_storage_bucket_iam_member" "files_object_viewer" {
  bucket = google_storage_bucket.files.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.cloud_run.email}"
}

# Permissão para upar objetos
resource "google_storage_bucket_iam_member" "files_object_creator" {
  bucket = google_storage_bucket.files.name
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:${google_service_account.cloud_run.email}"
}