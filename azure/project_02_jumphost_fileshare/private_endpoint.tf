# Zona para o endpoint Azure Files — não é a zona de Blob.
resource "azurerm_private_dns_zone" "prv-dns-sa-files" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = azurerm_resource_group.rg-aue.name
}

# Faz as VMs desta VNet consultarem a zona privada.
resource "azurerm_private_dns_zone_virtual_network_link" "link-prv-dns-sa-files" {
  name                 = "link-files-aue-01"
  private_dns_zone_id  = azurerm_private_dns_zone.prv-dns-sa-files.id
  virtual_network_id   = azurerm_virtual_network.vnet-workload-australia-01.id
  registration_enabled = false
}

resource "azurerm_private_endpoint" "prv-end-sa-files-aue" {
  name                = "prvend-sa-files-aue-01"
  location            = azurerm_resource_group.rg-aue.location
  resource_group_name = azurerm_resource_group.rg-aue.name
  subnet_id           = azurerm_subnet.snet-private-endpoints-aue.id

  private_service_connection {
    name                           = "psc-sa-files-aue-01"
    private_connection_resource_id = azurerm_storage_account.sa-files.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.prv-dns-sa-files.id]
  }

  # Garante que o link DNS já exista antes da associação da zona ao endpoint.
  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.link-prv-dns-sa-files
  ]
}