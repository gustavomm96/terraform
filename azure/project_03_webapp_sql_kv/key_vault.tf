# Criar e configurações do KV

# Pegar informações do usuario atual no azure
data "azurerm_client_config" "current-user-info" {}

resource "azurerm_key_vault" "kv-gm-01" {
  name                        = "kv-gmappdata${random_string.random.result}-aue-01" #Precisa ter uma parte criado aleatoriamente, pq após excluir o key vault ele vai para bin e fica uns dias lá e não permite criar outro com o mesmo nome
  location                    = azurerm_resource_group.rg-kv-aue.location
  resource_group_name         = azurerm_resource_group.rg-kv-aue.name
  rbac_authorization_enabled  = true
  enabled_for_disk_encryption = false
  tenant_id                   = data.azurerm_client_config.current-user-info.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  # Exemplo se fosse usar access_policy
  # access_policy {
  #   tenant_id = data.azurerm_client_config.current-user-info.tenant_id
  #   object_id = data.azurerm_client_config.current-user-info.object_id

  #   key_permissions = [
  #     "Get"
  #   ]

  #   secret_permissions = [
  #     "Get", "List", "Set", "Delete", "Purge"
  #   ]

  #   storage_permissions = [
  #     "Get"
  #   ]
  # }
  tags = local.common_tags
}

# Espera a propagação da permissão antes de criar secrets
resource "time_sleep" "wait_key_vault_permission" {
  create_duration = "60s"

  depends_on = [
    azurerm_role_assignment.kv_admin_secrets_officer
  ]
}

# Dar permissão para adicionar secrets no key vault
resource "azurerm_role_assignment" "kv_admin_secrets_officer" {
  scope                = azurerm_key_vault.kv-gm-01.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current-user-info.object_id
  principal_type       = "User"

  skip_service_principal_aad_check = true
  
}

# Secret fictício para demonstração
resource "azurerm_key_vault_secret" "api_demo_key" {
  name  = "ApiDemoKey"
  value = "CHAVE-DE-TESTE-001"
  #expiration_date = timeadd("${formatdate("YYYY-MM-DD", timestamp())}T00:00:00Z", "2160h") # ~90 dias
  content_type = "text/plain"

  key_vault_id = azurerm_key_vault.kv-gm-01.id
  depends_on = [ 
    time_sleep.wait_key_vault_permission
  ]
}

# Dar permissao no kv ao webapp
resource "azurerm_role_assignment" "webapp_kv_secrets_user" {
  scope                = azurerm_key_vault.kv-gm-01.id
  role_definition_name = "Key Vault Secrets User"
  # porque do identity[0]?
  # No recurso azurerm_linux_web_app, o bloco identity é uma lista de blocos, mesmo quando você define apenas uma identidade. 
  # Se um dia você usar identidades múltiplas (sistema + user-assigned), aí faria sentido acessar identity[0] e identity[1] separadamente.
  principal_id = azurerm_linux_web_app.web-linux.identity[0].principal_id

  skip_service_principal_aad_check = true
}

