# Project Name
variable "project_name" {
  description = "Nome curto usado para identificar o lab"
  type        = string
  default     = "gmapp-aue"
}

# Project Location
variable "project_location" {
  description = "Região do projeto"
  type        = string
  default     = "australiaeast"
}

# SQL Server Info
variable "admin_sql_login" {
  description = "Login do SQL Server"
  type        = string
  sensitive   = true
}

variable "admin_sql_pwd" {
  description = "Senha do SQL Server"
  type        = string
  sensitive   = true
}

variable "my_public_ip" {
  description = "Meu Ip publico para ser liberado no Firewall do SQL"
  type        = string
}

variable "user_entraid_login" {
  description = "User login"
  type        = string
}

variable "user_object_id" {
  description = "object ID do seu user ou do grupo usado para liberar SQL Serve"
  type        = string
}

# Vnet info
variable "vnet_aue_cidr" {
  description = "CIDR da VNet Australia"
  type        = string
  default     = "172.16.0.0/16"
}

# subnet app gw
variable "snet_appgw_cidr" {
  description = "CIDR da Subnet do app gateway"
  type        = string
  default     = "172.16.1.0/24"
}