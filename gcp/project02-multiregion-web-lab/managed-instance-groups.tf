# Criando o MIG
resource "google_compute_region_instance_group_manager" "web" {
  for_each = local.web_services

  project = google_project.lab.project_id

  name               = "${each.key}-mig"
  region             = each.value.region
  base_instance_name = "${each.key}-web"

  target_size = var.instances_per_service

  version {
    name              = "initial"
    instance_template = google_compute_instance_template.web[each.key].self_link
  }

  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.autohealing[each.key].self_link
    initial_delay_sec = 600
  }

  # minimal_action options:
  # NONE to forbid any actions
  # REFRESH to update without stopping instances. but if necessary it might perform a more disruptive action. NOTE: the Updater will attempt to perform that action only. However, if the Updater determines that the minimal action you specify is not enough to perform the update, it might perform a more disruptive action.
  # RESTART to restart existing instances
  # REPLACE to delete and create new instances from the target template.
  #   update_policy {
  #     type                  = "OPPORTUNISTIC"
  #     minimal_action        = "REPLACE" # uma mudança no template não dispara automaticamente a substituição de todas as VMs existentes. Já PROACTIVE aplica a nova configuração automaticamente por meio de atualização gradual
  #     max_surge_fixed       = 3         # Quantas VMs extras podem existir temporariamente durante uma atualização
  #     max_unavailable_fixed = 0         # Quantas VMs podem ficar indisponíveis durante uma atualização
  #   }
  # Para forçar a criação de novas instancias do MIG
  update_policy {
    type = "PROACTIVE"

    minimal_action                 = "REPLACE"
    most_disruptive_allowed_action = "REPLACE"

    replacement_method = "SUBSTITUTE"

    max_surge_fixed       = 3
    max_unavailable_fixed = 0

  }

  wait_for_instances = true
}