output "storage_url" {
  description = "URL da storage"
  value       = google_storage_bucket.files.url
}

output "storage_bucket_name" {
  description = "Cloud Storage bucket used by the API."
  value       = google_storage_bucket.files.name
}

output "cloud_run_service_url" {
  description = "Public HTTPS URL of the Cloud Run Files API."
  value       = google_cloud_run_v2_service.files_api.uri
}

output "artifact_registry_repository" {
  description = "Artifact Registry repository for application images."
  value       = google_artifact_registry_repository.files_api.name
}

output "cloud_run_service_account" {
  description = "Service account used by Cloud Run."
  value       = google_service_account.cloud_run.email
}