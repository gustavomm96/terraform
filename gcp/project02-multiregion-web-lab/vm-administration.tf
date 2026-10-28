# Windows VM - Administration
resource "google_compute_instance" "administration" {
  project = google_project.lab.project_id

  name         = "vm-administration-win"
  zone         = var.admin_zone
  machine_type = var.admin_machine_type

  deletion_protection = false

  tags = [
    "admin-windows"
  ]

  boot_disk {
    auto_delete = true

    initialize_params {
      image = var.admin_windows_image
      size  = var.admin_boot_disk_size_gb
      type  = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.administration.id
    network_ip = google_compute_address.administration.address
  }

  service_account {
    email = google_service_account.administration.email

    scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  metadata = {
    sysprep-specialize-script-ps1 = local.administration_bootstrap_script # Executa no primeiro boot da vm
    windows-startup-script-ps1    = local.administration_bootstrap_script # Executa nos boots posteriores, após o boot inicial
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  labels = {
    role        = "administration"
    environment = "dv"
    managed_by  = "terraform"
    owner       = "gustavo"
  }

  depends_on = [
    google_compute_router_nat.administration,
    google_compute_firewall.allow_iap_rdp,
    google_compute_firewall.allow_admin_http_to_web,
    google_compute_network_peering.administration_to_application,
    google_compute_network_peering.application_to_administration,
    google_secret_manager_secret_iam_member.administration_password_reader,
    google_project_iam_member.administration_log_writer
  ]
}