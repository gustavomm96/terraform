# Health checks vão ser associados ao lb
resource "google_compute_health_check" "load_balancer" {
  for_each = local.web_services

  project = google_project.lab.project_id
  name    = "${each.key}-lb-health-check"

  # configuration
  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3

  http_health_check {
    port         = 80
    request_path = "/health"
  }

  depends_on = [
    google_project_service.required["compute.googleapis.com"]
  ]
}

# auto healing vão ser associados ao MIG
resource "google_compute_health_check" "autohealing" {
  for_each = local.web_services

  project = google_project.lab.project_id
  name    = "${each.key}-autohealing-health-check"

  check_interval_sec  = 30
  timeout_sec         = 10
  healthy_threshold   = 2
  unhealthy_threshold = 5

  http_health_check {
    port         = 80
    request_path = "/health"
  }

  depends_on = [
    google_project_service.required["compute.googleapis.com"]
  ]
}