# Configuração da vpc de administração

resource "google_compute_network" "administration" {
  project = google_project.lab.project_id
  name    = "vpc-administration"

  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"

  depends_on = [
    google_project_service.required["compute.googleapis.com"]
  ]
}

resource "google_compute_subnetwork" "administration" {
  project = google_project.lab.project_id
  name    = "snet-administration"

  region        = var.region_admin
  ip_cidr_range = var.subnet_admin_cidr
  network       = google_compute_network.administration.id

  # Permite que VMs dessa subnet sem IP externo acessem APIs e serviços Google compatíveis,
  # configuração útil para uma subnet cujos servidores serão privados
  private_ip_google_access = true
}