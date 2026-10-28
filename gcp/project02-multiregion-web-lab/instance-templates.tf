# Criando template

# google_compute_instance_template = criar template global
# google_compute_region_instance_template = cria template regional
resource "google_compute_instance_template" "web" {
  for_each = local.web_services

  project = google_project.lab.project_id

  name_prefix  = "${each.key}-template-"
  description  = "Instance template for the ${each.key} web service."
  machine_type = var.machine_type
  region       = each.value.region

  # network tag - regras de firewall aplicada para essa tag
  tags = [
    "web-backend"
  ]

  disk {
    source_image = var.boot_image
    auto_delete  = true
    boot         = true
    disk_type    = "pd-standard"
    disk_size_gb = var.boot_disk_size_gb
  }

  network_interface {
    subnetwork = each.value.subnet_id
    # Removido esse bloco que as vms não vão ter IP publico, vai sair para internet via NAT
    # # PREMIUM recebe IP externo efêmero
    # access_config {
    #   network_tier = "PREMIUM"
    # }
  }

  service_account {
    email = google_service_account.web_servers.email

    scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
  # configurando o script do boot load
  metadata = {
    block-project-ssh-keys = "true"

    startup-script = templatefile(
      "${path.module}/scripts/startup.sh.tftpl",
      { # Passando as variaveis, no script vai estar referenciado com ${} = variaveis do terraform
        service_name = each.key
        page_title   = each.value.page_title
        region       = each.value.region
      }
    )
  }

  labels = {
    service     = each.key
    environment = "dv"
    managed_by  = "terraform"
    owner       = "gustavo"
  }

  # create_before_destroy = true permite o Terraform criar um novo modelo com nome único antes de remover
  # o antigo. Evita o conflito de tentar substituir um template mantendo exatamente o mesmo nome
  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    google_compute_firewall.allow_lb_http,
    google_compute_router_nat.web
  ]
}