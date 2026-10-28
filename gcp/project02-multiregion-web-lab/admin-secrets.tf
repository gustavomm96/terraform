# Regra da senha
resource "random_password" "administration" {
  length = 24

  upper   = true
  lower   = true
  numeric = true
  special = true

  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
  min_special = 2

  override_special = "!@#%_-"
}

# Cria o secret
# google_secret_manager_secret cria o repositório lógico. 
# google_secret_manager_secret_version armazena o valor de uma versão
resource "google_secret_manager_secret" "administration_password" {
  project   = google_project.lab.project_id
  secret_id = "administration-windows-password"

  replication {
    auto {}
  }

  labels = {
    role        = "administration"
    environment = "dv"
    managed_by  = "terraform"
    owner       = "gustavo"
  }

  depends_on = [
    google_project_service.required["secretmanager.googleapis.com"]
  ]
}

# Verion é colocar o valor no secret
# No final Secret: administration-windows-password value = version
resource "google_secret_manager_secret_version" "administration_password" {
  secret = google_secret_manager_secret.administration_password.id

  # Colcoar senha no segredo 
  secret_data = random_password.administration.result

  lifecycle {
    create_before_destroy = true
  }
}

# Dar permissão de leitura
resource "google_secret_manager_secret_iam_member" "administration_password_reader" {
  project   = google_project.lab.project_id
  secret_id = google_secret_manager_secret.administration_password.secret_id

  # Permissão apenas para ler esse segredo
  role = "roles/secretmanager.secretAccessor"

  member = "serviceAccount:${google_service_account.administration.email}"
}