variable "project_name" {
  description = "Nome curto usado nos recursos do lab"
  type        = string
  default     = "-gmlabs-cae-"
}

variable "admin_user" {
  description = "Admin user to login at windows VM"
  type        = string
}

variable "admin_password" {
  description = "Admin passoword to login at windows VM"
  type        = string
  sensitive   = true
}