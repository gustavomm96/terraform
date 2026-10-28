# NAT configuration
# NAT é regional, como estamos usando duas regiões é preciso criar 2 NATs

# Criar o nat route
resource "google_compute_router" "nat" {
  for_each = local.web_services

  project = google_project.lab.project_id
  name    = "${each.key}-nat-router"

  region  = each.value.region
  network = google_compute_network.application.id

  depends_on = [
    google_project_service.required["compute.googleapis.com"]
  ]
}

# Criar o NAT
resource "google_compute_router_nat" "web" {
  for_each = local.web_services

  project = google_project.lab.project_id
  name    = "${each.key}-nat"

  region = each.value.region
  router = google_compute_router.nat[each.key].name

  # O GCP aloca os endereços externos necessários ao NAT. Não é necessario criar um 
  # google_compute_address para cada gateway
  nat_ip_allocate_option = "AUTO_ONLY"

  # Deixa explícito quais workloads podem usar cada NAT. Uma futura subnet na mesma região 
  # não será incluída automaticamente.
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  # apenas subnets associadas nesse bloco vão usar o NAT gatewat
  subnetwork {
    name = each.value.subnet_id

    source_ip_ranges_to_nat = [
      "PRIMARY_IP_RANGE"
    ]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}