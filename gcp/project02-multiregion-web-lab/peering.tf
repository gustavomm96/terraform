# Criando o peering
# Precisa ser feito dos dois lados para fechar a conexão
resource "google_compute_network_peering" "administration_to_application" {
  name = "administration-to-application"

  network      = google_compute_network.administration.self_link
  peer_network = google_compute_network.application.self_link

  import_custom_routes = false
  export_custom_routes = false
}

resource "google_compute_network_peering" "application_to_administration" {
  name = "application-to-administration"

  network      = google_compute_network.application.self_link
  peer_network = google_compute_network.administration.self_link

  import_custom_routes = false
  export_custom_routes = false

  # O Google permite apenas uma operação de peering por vez entre redes envolvidas na conexão. 
  # fazemos sequencialmente para evitar conflito de operações simultâneas.
  depends_on = [
    google_compute_network_peering.administration_to_application
  ]
}

