# Mostrar os IP privados gerados na criação das vms windows
output "windows_private_ips" {
  description = "IP privado de cada VM Windows"

  value = {
    for chave, nic in azurerm_network_interface.windows :
    chave => nic.private_ip_address
  }
}

output "linux_private_ip" {
  description = "IP privado de cada VM Linux"
  value       = azurerm_network_interface.linux.private_ip_address
}

# Mostrar o PIP da vm do canada
output "pip-jumphost" {
  description = "Ip publico da vm bastion"
  value       = azurerm_public_ip.jump_canada.ip_address
}

output "sa-name" {
  description = "Nome final do SA"
  value       = azurerm_storage_account.sa-files.name
}