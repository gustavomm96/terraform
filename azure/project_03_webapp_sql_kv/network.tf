# VNET Australia
resource "azurerm_virtual_network" "vnet-aue-01" {
  name                = "vnet-${var.project_name}-01"
  location            = azurerm_resource_group.rg-gmapp.location
  resource_group_name = azurerm_resource_group.rg-gmapp.name
  address_space       = [var.vnet_aue_cidr]

  tags = local.common_tags
}

#Subnet Australia para app gw
resource "azurerm_subnet" "snet1-aue-01" {
  name                 = "sub-${var.project_name}-01"
  resource_group_name  = azurerm_resource_group.rg-gmapp.name
  virtual_network_name = azurerm_virtual_network.vnet-aue-01.name
  address_prefixes     = [var.snet_appgw_cidr]
}