# Main VPC
variable "vpc_cidr_main" {
  description = "CIDR da VPC do lado do app."
  type        = string
  default     = "10.10.0.0/16"
}

variable "availability_zones_main" {
  description = "AZs para as subnets do lado do app."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "allowed_admin_cidr" {
  description = "IP público autorizado a acessar o jump host, no formato /32"
  type        = string
}
# --------------------------

# Database configuration
variable "db_user" {
  description = "Usuario admin da base de dados"
  type        = string
}

variable "db_pwd" {
  description = "Senha do usuario admin da base de dados"
  type        = string
  sensitive   = true
}
# ------------------------------

# Bastion VPC configuration
variable "vpc_cidr_bastion" {
  description = "CIDR da VPC do lado do bastion."
  type        = string
  default     = "172.16.0.0/16"
}

variable "snet_cidr_bastion" {
  description = "CIDR da VPC do lado do bastion."
  type        = string
  default     = "172.16.10.0/24"
}

variable "availability_zones_bastion" {
  description = "AZs para as subnets do lado do app."
  type        = string
  default     = "us-west-2a"
}