locals {
  common_tags = {
    source = "terraform"
    owner  = "gustavo"
    type   = "project03-webapp"
  }
  appgw                          = "appgw-aue"
  backend_address_pool_name      = "${local.appgw}-bpool"
  frontend_port_name             = "${local.appgw}-feport"
  frontend_ip_configuration_name = "${local.appgw}-feip"
  http_setting_name              = "${local.appgw}-be-htst"
  listener_name                  = "${local.appgw}-httplstn"
  request_routing_rule_name      = "${local.appgw}-rqrt"
  redirect_configuration_name    = "${local.appgw}-rdrcfg"
}
