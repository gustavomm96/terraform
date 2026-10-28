# Project
variable "billing_account_id" {
  description = "ID da conta de faturamento existente, sem o prefixo billingAccounts/."
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "Nome de exibição do projeto."
  type        = string
  default     = "GCP Multiregion Web Lab"
}

variable "project_id_prefix" {
  description = "Prefixo do Project ID; receberá um sufixo aleatório."
  type        = string
  default     = "gm-multiregion-web"

  validation {
    condition = (
      length(var.project_id_prefix) >= 3 &&
      length(var.project_id_prefix) <= 21 &&
      can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.project_id_prefix))
    )

    error_message = "Use de 3 a 21 caracteres: letras minúsculas, números e hífens; comece com letra e termine com letra ou número."
  }
}

variable "org_id" {
  description = "ID da organização, se o projeto for criado nela. Use null para Sem organização."
  type        = string
  #default     = null
}
# ----------------------------------------------------------

# Regions
variable "region_videos" {
  description = "Região do grupo de servidores de vídeos."
  type        = string
}

variable "region_images" {
  description = "Região do grupo de servidores de imagens."
  type        = string
}

variable "region_admin" {
  description = "Região da subnet e dos recursos administrativos."
  type        = string
}

# ----------------------------------------------------------

# Network
variable "subnet_videos_cidr" {
  description = "Intervalo IPv4 da subnet do serviço de vídeos."
  type        = string
}

variable "subnet_images_cidr" {
  description = "Intervalo IPv4 da subnet do serviço de imagens."
  type        = string
}

variable "subnet_admin_cidr" {
  description = "Intervalo IPv4 da subnet administrativa."
  type        = string
}
# IP da vm administration
variable "private_ip_admin" {
  description = "IP privado reservado para a VM administrativa, dentro da subnet administrativa."
  type        = string
}
# ----------------------------------------------------------

# VM LINUX
variable "machine_type" {
  description = "Tipo de máquina das VMs dos serviços web."
  type        = string
  default     = "e2-small"
}

variable "boot_disk_size_gb" {
  description = "Tamanho do disco de inicialização de cada VM, em GB."
  type        = number
  default     = 10
}

variable "boot_image" {
  description = "Imagem ou família de imagem usada para inicializar as VMs."
  type        = string
  default     = "debian-cloud/debian-12"
}

variable "instances_per_service" {
  description = "Quantidade desejada de VMs em cada MIG."
  type        = number
  default     = 1

  validation {
    condition = (
      var.instances_per_service >= 1 &&
      floor(var.instances_per_service) == var.instances_per_service
    )

    error_message = "Informe um número inteiro maior ou igual a 1."
  }
}

# VM Windows
variable "admin_zone" {
  description = "Zona da VM administrativa; deve pertencer à admin_region."
  type        = string
}

variable "admin_machine_type" {
  description = "Tipo de máquina da VM Windows administrativa."
  type        = string
}

variable "admin_boot_disk_size_gb" {
  description = "Tamanho do disco de inicialização do Windows, em GB."
  type        = number
}

variable "admin_windows_image" {
  description = "Imagem ou família de imagem Windows Server."
  type        = string
}

variable "iap_admin_member" {
  description = "Principal IAM autorizado a abrir RDP via IAP, no formato user:email."
  type        = string

  validation {
    condition     = can(regex("^user:[^@ ]+@[^@ ]+$", var.iap_admin_member))
    error_message = "Informe o principal no formato user:seu-email@dominio.com."
  }
}

# Definir usuario do windows
variable "admin_windows_username" {
  description = "Nome da conta local criada na VM Windows."
  type        = string

  validation {
    condition = (
      length(var.admin_windows_username) >= 3 &&
      length(var.admin_windows_username) <= 20 &&
      can(regex("^[a-z][a-z0-9_-]*$", var.admin_windows_username))
    )

    error_message = "Use de 3 a 20 caracteres: comece com letra minúscula e use letras minúsculas, números, hífen ou underscore."
  }
}