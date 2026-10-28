# Load Balance configuration
# Como vai funcionar
# | Caminho                               | Destino                        |
# | ------------------------------------- | ------------------------------ |
# | /videos                               | videos-backend                 |
# | /videos/teste                         | videos-backend                 |
# | /images                               | images-backend                 |
# | /images/teste                         | images-backend                 |
# | /                                     | Backend padrão: videos-backend |
# | Qualquer caminho sem regra específica | Backend padrão: videos-backend |


# Criar o IP global do lb
resource "google_compute_global_address" "web" {
  project = google_project.lab.project_id
  name    = "web-lb-ip" # IP do frontend do lb

  address_type = "EXTERNAL"
  ip_version   = "IPV4"

  depends_on = [
    google_project_service.required["compute.googleapis.com"]
  ]
}

# lb
resource "google_compute_backend_service" "web" {
  for_each = local.web_services

  project = google_project.lab.project_id
  name    = "${each.key}-backend"

  load_balancing_scheme = "EXTERNAL_MANAGED"
  protocol              = "HTTP"
  port_name             = "http" # Foi o nome usado no managed port do MIG
  timeout_sec           = 30

  enable_cdn       = false
  session_affinity = "NONE"

  # Apontando para os health checks do lb
  health_checks = [
    google_compute_health_check.load_balancer[each.key].self_link
  ]

  backend {
    group = google_compute_region_instance_group_manager.web[each.key].instance_group

    balancing_mode  = "UTILIZATION"
    max_utilization = 0.8 # não cria autoscaling. Esse valor participa da configuração de capacidade do balanceamento.
    capacity_scaler = 1.0
  }

  # Habilitar log do lb
  log_config {
    enable      = true
    sample_rate = 1.0 # = 100% do log
  }
}

resource "google_compute_url_map" "web" {
  project = google_project.lab.project_id
  name    = "web-url-map"
  # Deixado o videos como regra padrão, ou seja, se for apenas o ip sem o /videos ou images, ele vai cair em videos
  default_service = google_compute_backend_service.web["videos"].self_link

  host_rule {
    hosts        = ["*"] # seleciona o matcher para qualquer hostname recebido no frontend.
    path_matcher = "web-services"
  }

  path_matcher {
    name = "web-services"

    default_service = google_compute_backend_service.web["videos"].self_link
    # /videos/* manda para os servers de videos
    path_rule {
      paths = [
        "/videos",
        "/videos/*"
      ]

      service = google_compute_backend_service.web["videos"].self_link
    }
    # /images/* manda para os servers de imagens
    path_rule {
      paths = [
        "/images",
        "/images/*"
      ]

      service = google_compute_backend_service.web["images"].self_link
    }
  }
}

# os lb do gcp precisa ter um proxy
# Cria um proxy HTTP que use este URL map para encaminhar as requisições
resource "google_compute_target_http_proxy" "web" {
  project = google_project.lab.project_id
  name    = "web-http-proxy"

  url_map = google_compute_url_map.web.self_link
}

resource "google_compute_global_forwarding_rule" "web" {
  project = google_project.lab.project_id
  name    = "web-http-forwarding-rule"

  load_balancing_scheme = "EXTERNAL_MANAGED"
  network_tier          = "PREMIUM" # usado para lb global

  ip_address  = google_compute_global_address.web.address
  ip_protocol = "TCP"
  port_range  = "80"

  target = google_compute_target_http_proxy.web.self_link
}