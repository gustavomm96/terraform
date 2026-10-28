# firewall rules

# Regra para liberar o acesso via IAP
resource "google_compute_firewall" "allow_iap_rdp" {
  project = google_project.lab.project_id
  name    = "administration-allow-iap-rdp"

  network   = google_compute_network.administration.id
  direction = "INGRESS"
  priority  = 1000

  description = "Allow RDP from IAP TCP forwarding to the administrative Windows VM."

  source_ranges = [
    "35.235.240.0/20" # Range de proxy para permitir acesso via IAP
  ]

  target_tags = [
    "admin-windows" # As VMs que desejo ter acesso via IAP, basta colocar essa network tag
  ]

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }
}