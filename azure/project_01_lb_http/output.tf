# PIP NAT Gateway
output "public-ip-natgw" {
  value = azurerm_public_ip.pip-natgw.ip_address
}

# Private IP vm-nginx-01
output "privateip-nic-vm-nginx-01" {
  value = azurerm_network_interface.nic-vm-nginx-01.private_ip_address
}

# Private IP vm-nginx-02
output "privateip-nic-vm-nginx-02" {
  value = azurerm_network_interface.nic-vm-nginx-02.private_ip_address
}

# PIP Frontend LB
output "lb_public_ip" {
  description = "IP público para acessar as páginas Nginx"
  value       = azurerm_public_ip.pip_lb.ip_address
}