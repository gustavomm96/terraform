# Public IP address used by the Load Balancer's frontend
resource "azurerm_public_ip" "pip_lb" {
  name                = "pip-lb-gmlabs-01"
  location            = azurerm_resource_group.rg-gmlabs.location
  resource_group_name = azurerm_resource_group.rg-gmlabs.name

  allocation_method = "Static"
  sku               = "Standard"

  tags = local.common_tags
}


# Public Load Balancer
resource "azurerm_lb" "lb_web" {
  name                = "lb-web-gmlabs-01"
  location            = azurerm_resource_group.rg-gmlabs.location
  resource_group_name = azurerm_resource_group.rg-gmlabs.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "fend-http"
    public_ip_address_id = azurerm_public_ip.pip_lb.id
  }

  tags = local.common_tags
}

# A single backend pool for both VMs
resource "azurerm_lb_backend_address_pool" "bpool-web" {
  name            = "bpool-web"
  loadbalancer_id = azurerm_lb.lb_web.id
}

# The NIC for VM 01 is added to the backend pool
resource "azurerm_network_interface_backend_address_pool_association" "associate-bpool-vm01" {
  network_interface_id    = azurerm_network_interface.nic-vm-nginx-01.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.bpool-web.id
}

# The NIC for VM 02 is added to the backend pool
resource "azurerm_network_interface_backend_address_pool_association" "associate-bpool-vm02" {
  network_interface_id    = azurerm_network_interface.nic-vm-nginx-02.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.bpool-web.id
}

# Check if Nginx is responding on port 80
resource "azurerm_lb_probe" "http" {
  name            = "probe-http-80"
  loadbalancer_id = azurerm_lb.lb_web.id
  protocol        = "Http"
  port            = 80
  request_path    = "/"
}

# Entry rule: LB's public IP:80 -> backend pool:80
resource "azurerm_lb_rule" "http" {
  name                           = "rule-http-80"
  loadbalancer_id                = azurerm_lb.lb_web.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "fend-http"
  # I'm using square brackets because I'm passing two IDs
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpool-web.id]
  probe_id                 = azurerm_lb_probe.http.id

  # The subnets already have a NAT gateway for outbound traffic.
  disable_outbound_snat = true
}

