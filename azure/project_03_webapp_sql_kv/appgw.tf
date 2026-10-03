# Criar PIP para app gw
resource "azurerm_public_ip" "pip-appgw" {
  name                = "pip-appgw-01"
  location            = azurerm_resource_group.rg-gmapp.location
  resource_group_name = azurerm_resource_group.rg-gmapp.name

  allocation_method = "Static"
  sku               = "Standard"

  tags = local.common_tags
}

# Application Gateway
resource "azurerm_application_gateway" "appgw-aue-01" {
  name                = "gm-appgw-aue-01"
  resource_group_name = azurerm_resource_group.rg-gmapp.name
  location            = azurerm_resource_group.rg-gmapp.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.snet1-aue-01.id
  }

  # Frontend: uma única porta 80 para os dois sites HTTP
  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.pip-appgw.id
  }

  # Backend 1: Web App
  backend_address_pool {
    name = "pool-gmapp-webapp"

    fqdns = [
      azurerm_linux_web_app.web-linux.default_hostname
    ]
  }

  # Backend 2: Storage Static Website
  backend_address_pool {
    name = "pool-gmlaboratorio-static-site"

    fqdns = [
      azurerm_storage_account.sa-site.primary_web_host
    ]
  }

  # Backend HTTP settings: Web App
  backend_http_settings {
    name                                = "https-webapp-443"
    cookie_based_affinity               = "Disabled"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 30
    pick_host_name_from_backend_address = true # Precisa de true pq o web app vai ter o certifcado da microsoft e outra URL
    probe_name                          = "probe-webapp"
  }

  # Backend HTTP settings: Storage Static Website
  backend_http_settings {
    name                                = "https-static-site-443"
    cookie_based_affinity               = "Disabled"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 30
    pick_host_name_from_backend_address = true
    probe_name                          = "probe-static-site"
  }

  # Probe: Web App
  probe {
    name                                      = "probe-webapp"
    protocol                                  = "Https"
    path                                      = "/api/status"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true

    match {
      status_code = ["200-399"]
    }
  }

  # Probe: Storage Static Website
  probe {
    name                                      = "probe-static-site"
    protocol                                  = "Https"
    path                                      = "/"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true

    match {
      status_code = ["200-399"]
    }
  }

  # Listener 1: Web App
  # Mesmo IP público e mesma porta 80; diferencia pelo Host header.
  http_listener {
    name                           = "listener-webapp-http"
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
    host_name                      = "gmapp.gustalabs.cloud"
  }

  # Listener 2: Storage Static Website
  # Mesmo IP público e mesma porta 80; diferencia pelo Host header.
  http_listener {
    name                           = "listener-static-http"
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
    host_name                      = "gmlaboratorio.gustalabs.cloud"
  }

  # Regra 1: gmapp.gustalabs.cloud -> Web App
  request_routing_rule {
    name                       = "rule-webapp-http"
    priority                   = 100
    rule_type                  = "Basic"
    http_listener_name         = "listener-webapp-http"
    backend_address_pool_name  = "pool-gmapp-webapp"
    backend_http_settings_name = "https-webapp-443"
  }

  # Regra 2: gmlaboratorio.gustalabs.cloud -> Storage Static Website
  request_routing_rule {
    name                       = "rule-static-http"
    priority                   = 110
    rule_type                  = "Basic"
    http_listener_name         = "listener-static-http"
    backend_address_pool_name  = "pool-gmlaboratorio-static-site"
    backend_http_settings_name = "https-static-site-443"
  }

  tags = local.common_tags
}
