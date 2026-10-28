# network configuration

# VPC
resource "google_compute_network" "application" {
  project = google_project.lab.project_id
  name    = "vpc-gm-web-application"

  auto_create_subnetworks = false # Vou criar as subnets separadoem outro block
  # REGIONAL não impede a comunicação entre as duas subnets da mesma VPC em regioes distintas. 
  # Não precisamos de GLOBAL apenas porque usa duas regiões
  routing_mode = "REGIONAL" # Global para Cloud Router/BGP

  # precisa da API compute configurada
  depends_on = [
    google_project_service.required["compute.googleapis.com"]
  ]
}

# Subnets
resource "google_compute_subnetwork" "videos" {
  project = google_project.lab.project_id
  name    = "snet-videos"

  region        = var.region_videos
  ip_cidr_range = var.subnet_videos_cidr
  network       = google_compute_network.application.id
}

resource "google_compute_subnetwork" "images" {
  project = google_project.lab.project_id
  name    = "snet-images"

  region        = var.region_images
  ip_cidr_range = var.subnet_images_cidr
  network       = google_compute_network.application.id
}