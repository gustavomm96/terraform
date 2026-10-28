# Firewall rules da vpc de aplicação

resource "google_compute_firewall" "allow_lb_http" {
  project = google_project.lab.project_id
  name    = "gm-application-allow-lb-http"

  network   = google_compute_network.application.id
  direction = "INGRESS"
  priority  = 1000

  description = "Allow HTTP from Google load balancer proxies and health check systems to web backends."

  # Esses ranges são os intervalos usados pelos proxies do Google e pelos sistemas de health check para alcançar as VMs
  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22"
  ]

  # regra não será aplicada para todas as VMs da VPC que tem essa network tag web-backend
  target_tags = [
    "web-backend" # Essa tag vai estar nos instance templates
  ]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_firewall" "allow_admin_http_to_web" {
  project = google_project.lab.project_id
  name    = "application-allow-admin-http"

  network   = google_compute_network.application.id
  direction = "INGRESS"
  priority  = 1000

  description = "Allow HTTP diagnostics from the administrative VM to application backends."

  source_ranges = [
    "${google_compute_address.administration.address}/32"
  ]

  target_tags = [
    "web-backend"
  ]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}