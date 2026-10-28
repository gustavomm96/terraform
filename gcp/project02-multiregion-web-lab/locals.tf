# Locals do Linux (application)
locals {
  web_services = {
    videos = {
      region     = var.region_videos
      subnet_id  = google_compute_subnetwork.videos.id
      page_title = "Videos Service"
    }

    images = {
      region     = var.region_images
      subnet_id  = google_compute_subnetwork.images.id
      page_title = "Images Service"
    }
  }
}
# Locals do windows
locals {
  administration_bootstrap_script = templatefile(
    "${path.module}/scripts/windows-startup.ps1.tftpl",
    {
      username       = var.admin_windows_username
      secret_version = google_secret_manager_secret_version.administration_password.name
    }
  )
}