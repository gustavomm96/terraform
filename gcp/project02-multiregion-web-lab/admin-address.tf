# Reservar um ip interno para a vm administration, com isso, não é precisa criar regra de firewall para
# toda a rede
resource "google_compute_address" "administration" {
  project = google_project.lab.project_id
  name    = "administration-private-ip"

  region       = var.region_admin
  address_type = "INTERNAL"

  subnetwork = google_compute_subnetwork.administration.id
  address    = var.private_ip_admin
}