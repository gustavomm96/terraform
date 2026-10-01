# CANADA
# VNET Canada
resource "azurerm_virtual_network" "vnet-jumphost-canada-01" {
  name                = "vnet-${var.project_name}-cae-01"
  location            = azurerm_resource_group.rg-cae.location
  resource_group_name = azurerm_resource_group.rg-cae.name
  address_space       = [var.jump_vnet_cidr]

  tags = local.common_tags
}

#Subnet Canada
resource "azurerm_subnet" "snet1-cae" {
  name                 = "sub-${var.project_name}-cae-01"
  resource_group_name  = azurerm_resource_group.rg-cae.name
  virtual_network_name = azurerm_virtual_network.vnet-jumphost-canada-01.name
  address_prefixes     = [var.jump_snet_cidr]
}

# NSG Canada
resource "azurerm_network_security_group" "nsg-canada" {
  name                = "${module.naming.network_security_group.name}-cae-01"
  location            = azurerm_resource_group.rg-cae.location
  resource_group_name = azurerm_resource_group.rg-cae.name

  security_rule {
    name                       = "Allow-RDP-MyHome"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = var.allowed_admin_cidr
    destination_address_prefix = "*"
    #    destination_address_prefixes = ["10.10.1.4", "10.10.2.4"] # Example of using prefixes for more than one IP address
  }

  tags = local.common_tags
}
# Associate the NSG with the Canada subnet
resource "azurerm_subnet_network_security_group_association" "nsg-snet-cae" {
  subnet_id                 = azurerm_subnet.snet1-cae.id
  network_security_group_id = azurerm_network_security_group.nsg-canada.id
}

# --------------------------------------------------------------------------------------
# Australia East

# VNET Australia
resource "azurerm_virtual_network" "vnet-workload-australia-01" {
  name                = "vnet-${var.project_name}-aue-01"
  location            = azurerm_resource_group.rg-aue.location
  resource_group_name = azurerm_resource_group.rg-aue.name
  address_space       = [var.workload_vnet_cidr]

  tags = local.common_tags
}


#Subnet Australia
resource "azurerm_subnet" "snet1-aue" {
  name                 = "sub-${var.project_name}-aue-01"
  resource_group_name  = azurerm_resource_group.rg-aue.name
  virtual_network_name = azurerm_virtual_network.vnet-workload-australia-01.name
  address_prefixes     = [var.workload_snet_cidr]
}

# Subnet dedicada ao Private Endpoint, na VNet australia.
resource "azurerm_subnet" "snet-private-endpoints-aue" {
  name                 = "snet-private-endpoints-aue-02"
  resource_group_name  = azurerm_resource_group.rg-aue.name
  virtual_network_name = azurerm_virtual_network.vnet-workload-australia-01.name
  address_prefixes     = [var.prvent_aue_snet_cidr]

  private_endpoint_network_policies = "Disabled"
}

# NSG Australia
resource "azurerm_network_security_group" "nsg-australia" {
  name                = "${module.naming.network_security_group.name}-aue-01"
  location            = azurerm_resource_group.rg-aue.location
  resource_group_name = azurerm_resource_group.rg-aue.name

  security_rule {
    name                       = "Allow-RDP-From-Canada"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "10.50.1.0/24"
    destination_address_prefix = "*"
    #    destination_address_prefixes = ["10.10.1.4", "10.10.2.4"] # Example of using prefixes for more than one IP address
  }
  security_rule {
    name                       = "Allow-SSH-From-Canada"
    priority                   = 301
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.50.1.0/24"
    destination_address_prefix = "*"
    #    destination_address_prefixes = ["10.10.1.4", "10.10.2.4"] # Example of using prefixes for more than one IP address
  }

  tags = local.common_tags
}
# Associate the NSG with the Australia subnet
resource "azurerm_subnet_network_security_group_association" "nsg-snet-aue" {
  subnet_id                 = azurerm_subnet.snet1-aue.id
  network_security_group_id = azurerm_network_security_group.nsg-australia.id
}

# -------------------------------------------------------------------

# PEERINGs
# Canada -> Australia
resource "azurerm_virtual_network_peering" "canada-to-australia" {
  name                      = "peer-canada-to-australia"
  resource_group_name       = azurerm_resource_group.rg-cae.name
  virtual_network_name      = azurerm_virtual_network.vnet-jumphost-canada-01.name
  remote_virtual_network_id = azurerm_virtual_network.vnet-workload-australia-01.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = false

  depends_on = [
    azurerm_virtual_network.vnet-jumphost-canada-01,
    azurerm_virtual_network.vnet-workload-australia-01
  ]
}

# Australia -> Canada
resource "azurerm_virtual_network_peering" "australia-to-canada" {
  name                      = "peer-australia-to-canada"
  resource_group_name       = azurerm_resource_group.rg-aue.name
  virtual_network_name      = azurerm_virtual_network.vnet-workload-australia-01.name
  remote_virtual_network_id = azurerm_virtual_network.vnet-jumphost-canada-01.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = false

  depends_on = [
    azurerm_virtual_network.vnet-jumphost-canada-01,
    azurerm_virtual_network.vnet-workload-australia-01
  ]
}
