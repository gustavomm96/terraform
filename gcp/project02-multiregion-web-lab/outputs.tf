# Project outputs
output "project_id" {
  description = "Project ID criado pelo Terraform."
  value       = google_project.lab.project_id
}

output "project_number" {
  description = "Número do projeto criado."
  value       = google_project.lab.number
}
# -------------------------------------------------------------
# Network outputs
output "application_vpc_name" {
  description = "Nome da VPC de aplicação."
  value       = google_compute_network.application.name
}

output "videos_subnet" {
  description = "Configuração da subnet de vídeos."

  value = {
    name   = google_compute_subnetwork.videos.name
    region = google_compute_subnetwork.videos.region
    cidr   = google_compute_subnetwork.videos.ip_cidr_range
  }
}

output "images_subnet" {
  description = "Configuração da subnet de imagens."

  value = {
    name   = google_compute_subnetwork.images.name
    region = google_compute_subnetwork.images.region
    cidr   = google_compute_subnetwork.images.ip_cidr_range
  }
}
# VPC administration
output "administration_vpc_name" {
  description = "Nome da VPC administrativa."
  value       = google_compute_network.administration.name
}

output "administration_subnet" {
  description = "Configuração da subnet administrativa."

  value = {
    name   = google_compute_subnetwork.administration.name
    region = google_compute_subnetwork.administration.region
    cidr   = google_compute_subnetwork.administration.ip_cidr_range
  }
}

output "administration_private_ip" {
  description = "Reserved private IP address for the administrative VM."
  value       = google_compute_address.administration.address
}

output "vpc_peering_names" {
  description = "Peering configurations connecting the administration and application VPCs."

  value = {
    administration_to_application = google_compute_network_peering.administration_to_application.name
    application_to_administration = google_compute_network_peering.application_to_administration.name
  }
}
# -------------------------------------------------------------

# IAM service account info
output "web_servers_service_account" {
  description = "Service account used by the web server instances."
  value       = google_service_account.web_servers.email
}
# IAM Adminitration service account
output "administration_service_account" {
  description = "Service account used by the administrative Windows VM."
  value       = google_service_account.administration.email
}

# Instance template
output "web_instance_templates" {
  description = "Instance templates created for each web service."

  value = { # chave, valor
    for service, template in google_compute_instance_template.web :
    service => template.self_link # => No objeto de saída, use o nome do serviço como chave e o self_link daquele template como valor.
  }
}

# MIG
output "web_managed_instance_groups" {
  description = "Managed instance groups created for each web service."

  value = {
    for service, mig in google_compute_region_instance_group_manager.web :
    service => {
      name           = mig.name
      region         = mig.region
      instance_group = mig.instance_group
    }
  }
}

# Load Balance
output "load_balancer_ip" {
  description = "Public IPv4 address of the global application load balancer."
  value       = google_compute_global_address.web.address
}

output "web_urls" {
  description = "HTTP endpoints used to validate path-based routing."

  value = {
    home   = "http://${google_compute_global_address.web.address}/"
    videos = "http://${google_compute_global_address.web.address}/videos"
    images = "http://${google_compute_global_address.web.address}/images"
  }
}

# VM Administration
output "administration_vm" {
  description = "Administrative Windows VM connection details."

  value = {
    name       = google_compute_instance.administration.name
    zone       = google_compute_instance.administration.zone
    private_ip = google_compute_address.administration.address
  }
}

output "administration_vm_name" {
  description = "Name of the administrative Windows VM."
  value       = google_compute_instance.administration.name
}

output "administration_vm_zone" {
  description = "Zone of the administrative Windows VM."
  value       = google_compute_instance.administration.zone
}

output "administration_windows_username" {
  description = "Local Windows account used for RDP."
  value       = var.admin_windows_username
}

output "administration_password_secret_id" {
  description = "Secret Manager secret containing the Windows password."
  value       = google_secret_manager_secret.administration_password.secret_id
}

output "administration_password_secret_version" {
  description = "Secret version used by the Windows bootstrap."
  value       = google_secret_manager_secret_version.administration_password.version
}