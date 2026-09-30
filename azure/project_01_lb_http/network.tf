# NSG
resource "azurerm_network_security_group" "nsg-gmlabs" {
  name                = "nsg${var.project_name}01"
  location            = azurerm_resource_group.rg-gmlabs.location
  resource_group_name = azurerm_resource_group.rg-gmlabs.name

  security_rule {
    name                       = "Allow-http"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    #    destination_address_prefixes = ["10.10.1.4", "10.10.2.4"] # Example of using prefixes for more than one IP address
  }

  tags = local.common_tags
}

# VNET
resource "azurerm_virtual_network" "vnet-gmlabs-01" {
  name                = "vnet${var.project_name}01"
  location            = azurerm_resource_group.rg-gmlabs.location # Since it's in the same location as the main, I don't use the output
  resource_group_name = azurerm_resource_group.rg-gmlabs.name
  address_space       = ["10.10.0.0/16"]

  tags = local.common_tags
}
# I had run it the first time with the default name “example,” and after creating it, I changed the name
# This move will update the tfstate and won't cause it to destroy everything and recreate it
#moved {
#  from = azurerm_virtual_network.example
#  to   = azurerm_virtual_network.vnet-gmlabs-01
#}

# I had to separate the subnet from the VNet block; I'll need the subnet ID for the NAT gateway.
#Sub1
resource "azurerm_subnet" "snet1" {
  name                 = "sub${var.project_name}01"
  resource_group_name  = azurerm_resource_group.rg-gmlabs.name
  virtual_network_name = azurerm_virtual_network.vnet-gmlabs-01.name
  address_prefixes     = ["10.10.1.0/24"]
}
#Sub2
resource "azurerm_subnet" "snet2" {
  name                 = "sub${var.project_name}02"
  resource_group_name  = azurerm_resource_group.rg-gmlabs.name
  virtual_network_name = azurerm_virtual_network.vnet-gmlabs-01.name
  address_prefixes     = ["10.10.2.0/24"]
}

# Associate the NSG with the subnets
resource "azurerm_subnet_network_security_group_association" "nsg-snet1" {
  subnet_id                 = azurerm_subnet.snet1.id
  network_security_group_id = azurerm_network_security_group.nsg-gmlabs.id
  depends_on = [
    azurerm_network_security_group.nsg-gmlabs,
    azurerm_virtual_network.vnet-gmlabs-01
  ]
}

resource "azurerm_subnet_network_security_group_association" "nsg-snet2" {
  subnet_id                 = azurerm_subnet.snet2.id
  network_security_group_id = azurerm_network_security_group.nsg-gmlabs.id
  depends_on = [
    azurerm_network_security_group.nsg-gmlabs,
    azurerm_virtual_network.vnet-gmlabs-01
  ]
}

# PIP
resource "azurerm_public_ip" "pip-natgw" {
  name                = "pip-natgw${var.project_name}01"
  location            = azurerm_resource_group.rg-gmlabs.location
  resource_group_name = azurerm_resource_group.rg-gmlabs.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

# Nat gateway
resource "azurerm_nat_gateway" "natgw" {
  name                = "natgw${var.project_name}01"
  location            = azurerm_resource_group.rg-gmlabs.location
  resource_group_name = azurerm_resource_group.rg-gmlabs.name
  sku_name            = "Standard"
  tags                = local.common_tags
}

# Link the NAT gateway to PIP
resource "azurerm_nat_gateway_public_ip_association" "associate-pip-natgw" {
  nat_gateway_id       = azurerm_nat_gateway.natgw.id
  public_ip_address_id = azurerm_public_ip.pip-natgw.id
}

# Link the NAT gateway with subnet1
resource "azurerm_subnet_nat_gateway_association" "associate-natgw-snet1" {
  subnet_id      = azurerm_subnet.snet1.id
  nat_gateway_id = azurerm_nat_gateway.natgw.id
}

# Link the NAT gateway with subnet2
resource "azurerm_subnet_nat_gateway_association" "associate-natgw-snet2" {
  subnet_id      = azurerm_subnet.snet2.id
  nat_gateway_id = azurerm_nat_gateway.natgw.id
}
