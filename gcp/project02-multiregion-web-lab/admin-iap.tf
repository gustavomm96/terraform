# Permitindo acesso rdp via IAP
resource "google_iap_tunnel_instance_iam_member" "administration_rdp" {
  project = google_project.lab.project_id

  zone     = google_compute_instance.administration.zone
  instance = google_compute_instance.administration.name

  role   = "roles/iap.tunnelResourceAccessor"
  member = var.iap_admin_member

  condition {
    title       = "rdp-only"
    description = "Allow IAP TCP forwarding only to the Windows RDP port."
    expression  = "destination.port == 3389"
  }

  depends_on = [
    google_project_service.required["iap.googleapis.com"]
  ]
}