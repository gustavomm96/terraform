# Web App Linux
resource "azurerm_linux_web_app" "web-linux" {
  name                = "gmapp-web-ae-01"
  location            = azurerm_resource_group.rg-gmapp.location
  resource_group_name = azurerm_resource_group.rg-gmapp.name
  service_plan_id     = azurerm_service_plan.asp-linux.id

  site_config {
    application_stack {
      dotnet_version = "8.0"
      # Usado para testar uma imagem docker
      #docker_image_name = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
    }
    always_on = false # obrigatório para F1
  }

  identity {
    type = "SystemAssigned"
  }

  # Connection string para o SQL, sem senha (Authentication=Active Directory Default)
  connection_string {
    name = "AZURE_SQL_CONNECTIONSTRING"
    type = "SQLAzure"
    #value = "Server=tcp:${azurerm_mssql_server.gm-sql-server.name}.database.windows.net,1433;Database=${azurerm_mssql_database.gm-slq-db.name};Authentication=Active Directory Default;Encrypt=True;TrustServerCertificate=False;"
    value = "Server=tcp:gmsqlserver-aue-01.database.windows.net,1433;Database=gmsqldb-aue-01;Authentication=Active Directory Default;Encrypt=True;TrustServerCertificate=False;"
  }

  # App settings básicos
  app_settings = {
    "WEBSITE_WEBDEPLOY_USE_SCM" = "false"
    # Espelha a connection string como app setting
    "AZURE_SQL_CONNECTIONSTRING" = "Server=tcp:gmsqlserver-aue-01.database.windows.net,1433;Database=gmsqldb-aue-01;Authentication=Active Directory Default;Encrypt=True;TrustServerCertificate=False;"
    #"DOCKER_REGISTRY_SERVER_URL" = "https://mcr.microsoft.com"
    # Referência ao secret no Key Vault
    "API_DEMO_KEY" = "@Microsoft.KeyVault(SecretUri=https://${azurerm_key_vault.kv-gm-01.name}.vault.azure.net/secrets/${azurerm_key_vault_secret.api_demo_key.name})"
  }

  tags = local.common_tags
}