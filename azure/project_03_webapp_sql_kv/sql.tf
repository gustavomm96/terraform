# Criar o server SQL
resource "azurerm_mssql_server" "gm-sql-server" {
  name                = "gmsqlserver-aue-01"
  resource_group_name = azurerm_resource_group.rg-gmapp.name
  location            = azurerm_resource_group.rg-gmapp.location
  version             = "12.0"

  # Login information
  administrator_login          = var.admin_sql_login
  administrator_login_password = var.admin_sql_pwd

  # Admin Microsoft Entra
  azuread_administrator {
    login_username = data.azurerm_client_config.current-user-info.client_id
    object_id      = data.azurerm_client_config.current-user-info.object_id
    tenant_id      = data.azurerm_client_config.current-user-info.tenant_id

    # Se quiser que só Entra possa logar (opcional para lab):
    # azuread_authentication_only = true
  }
  # Security
  minimum_tls_version           = "1.2"
  public_network_access_enabled = true
}

# Criar o database
resource "azurerm_mssql_database" "gm-slq-db" {
  name      = "gmsqldb-aue-01"
  server_id = azurerm_mssql_server.gm-sql-server.id
  collation = "SQL_Latin1_General_CP1_CI_AS"
  #license_type = "LicenseIncluded" # Serverless não suporta license_type
  max_size_gb = 2

  # Serverless no modelo vCore (mais barato para lab)
  sku_name = "GP_S_Gen5_1"

  # Configurações específicas do tier Serverless
  auto_pause_delay_in_minutes = 60
  min_capacity                = 0.5
  read_scale                  = false
  zone_redundant              = false

  tags = local.common_tags

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = false
  }
}

# Regra de firewall para liberar para meu IP
resource "azurerm_mssql_firewall_rule" "allow-my-home-ip" {
  name             = "allow-my-home-ip"
  server_id        = azurerm_mssql_server.gm-sql-server.id
  start_ip_address = var.my_public_ip
  end_ip_address   = var.my_public_ip
}

# Essa regra é o equivalente Terraform da opção “Allow Azure services and resources to access this server”
resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.gm-sql-server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# resource "azurerm_sql_active_directory_administrator" "sql-ad-admin" {
#   server_name         = azurerm_mssql_server.gm-sql-server.name
#   resource_group_name = azurerm_resource_group.rg-gmapp.name

#   login              = var.user_entraid_login
#   object_id          = var.user_object_id
#   tenant_id          = data.azurerm_client_config.current.tenant_id
# }

# resource "azurerm_mssql_server_azuread_administrator" "sql-ad-admin" {
#   server_id = azurerm_mssql_server.gm-sql-server.id

#   login     = var.user_entraid_login
#   object_id = var.user_object_id
#   tenant_id = data.azurerm_client_config.current.tenant_id
# }