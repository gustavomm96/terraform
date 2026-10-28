locals {
  required_apis = toset([
    "compute.googleapis.com", # VPC, subnets, firewall, VMs, instance templates, MIGs e componentes do balanceador
    "iam.googleapis.com",     # Service account dedicada às VMs
    "iap.googleapis.com",
    "secretmanager.googleapis.com", # Para gerenciar as senhas do windows vamos usar o secret manager
    "logging.googleapis.com",
    "monitoring.googleapis.com"
  ])
}

resource "google_project_service" "required" {
  for_each = local.required_apis

  project = google_project.lab.project_id
  service = each.value

  disable_on_destroy = false
}