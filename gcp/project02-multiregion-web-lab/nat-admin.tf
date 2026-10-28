# NAT da VPC admin
# Mesmo ele estando na mesma regio do MIG videos, o google nat não permite ter 2 vpc para 1 nat
resource "google_compute_router" "administration_nat" {
  project = google_project.lab.project_id
  name    = "nat-router-administration"

  region  = var.region_admin
  network = google_compute_network.administration.id

  depends_on = [
    google_project_service.required["compute.googleapis.com"]
  ]
}

resource "google_compute_router_nat" "administration" {
  project = google_project.lab.project_id
  name    = "nat-administration"

  region = var.region_admin
  router = google_compute_router.administration_nat.name

  nat_ip_allocate_option = "AUTO_ONLY"

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name = google_compute_subnetwork.administration.id

    source_ip_ranges_to_nat = [
      "PRIMARY_IP_RANGE"
    ]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}