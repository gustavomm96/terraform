output "kv-appdata-url" {
  description = "URL do Key Vault criada"
  value       = azurerm_key_vault.kv-gm-01.vault_uri
}

output "static-website-name" {
  description = "URL pública do site estático no Azure Storage"
  # Não é seguro dar output da URL do SA
  #value       = azurerm_storage_account.sa-site.primary_access_key
  value = azurerm_storage_account.sa-site.name
}

output "app-gw-ipp" {
  description = "IP publico do application gateway"
  value       = azurerm_public_ip.pip-appgw.ip_address
}