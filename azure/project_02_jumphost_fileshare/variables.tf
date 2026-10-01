variable "project_name" {
  description = "Nome curto usado para identificar o lab"
  type        = string
  default     = "fileslab"
}

variable "workload_location" {
  description = "Região das VMs Windows e Linux e do Azure Files"
  type        = string
  default     = "australiaeast"
}

variable "jump_location" {
  description = "Região da VM jump host"
  type        = string
  default     = "canadaeast"
}

# Vnets
variable "workload_vnet_cidr" {
  description = "CIDR da VNet das VMs clientes"
  type        = string
  default     = "172.16.0.0/16"
}

variable "jump_vnet_cidr" {
  description = "CIDR da VNet do jump host"
  type        = string
  default     = "10.50.0.0/16"
}

variable "workload_snet_cidr" {
  description = "CIDR da snet das VMs clientes"
  type        = string
  default     = "172.16.1.0/24"
}

variable "prvent_aue_snet_cidr" {
  description = "CIDR da snet das VMs clientes"
  type        = string
  default     = "172.16.100.0/27"
}

variable "jump_snet_cidr" {
  description = "CIDR da snet do jump host"
  type        = string
  default     = "10.50.1.0/24"
}

variable "allowed_admin_cidr" {
  description = "IP público autorizado a acessar o jump host, no formato /32"
  type        = string
}

# VM SKU
variable "vm_size" {
  description = "SKU usada pelas três VMs do lab"
  type        = string
  default     = "Standard_B2ls_v2"
}

# VM Windows User
variable "admin_username" {
  description = "Admin user to login at windows VM"
  type        = string
}

variable "windows_admin_password" {
  description = "Admin passoword to login at windows VM"
  type        = string
  sensitive   = true
}

# VM Linux SSH Key
variable "linux_ssh_public_key_path" {
  description = "Caminho de um arquivo .pub acessível ao Terraform no Windows"
  type        = string
}

# IP Publico de quem esta executando o terraform
variable "terraform_runner_public_ip" {
  description = "IPv4 público do local de execução do Terraform, permitido no endpoint público da Storage Account."
  type        = string
}

