resource "azurerm_storage_account" "sa-files" {
  name                     = "gmlabs${random_string.random.result}" # Precisa estar disponível no Azure
  resource_group_name      = azurerm_resource_group.rg-aue.name
  location                 = azurerm_resource_group.rg-aue.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  # IMPORTANTE: Se você der disabled no public access, não vai mais conseguir obter informações da SA e vai receber 403 authorized em plan e apply, por isso liberei apenas para meu IP
  #public_network_access    = "Disabled"
  public_network_access = "Enabled"

  # network_rules.default_action = "Deny" e ip_rules representa a opção do portal “Enabled from selected networks”
  network_rules {
    default_action = "Deny"
    ip_rules       = [var.terraform_runner_public_ip]
    bypass         = ["None"]
  }

  tags = local.common_tags
}

resource "azurerm_storage_share" "shared" {
  name               = "fileshare-data"
  storage_account_id = azurerm_storage_account.sa-files.id
  quota              = 10
}

resource "azurerm_storage_share_directory" "documents" {
  name              = "docs"
  storage_share_url = azurerm_storage_share.shared.url
}

resource "azurerm_storage_share_file" "leia_me" {
  name              = "leia-me.txt"
  storage_share_url = azurerm_storage_share.shared.url
  path              = azurerm_storage_share_directory.documents.name
  source            = "${path.module}/files/readme.txt"
  content_type      = "text/plain"

  depends_on = [azurerm_storage_share_directory.documents]
}

# Habilitar o SMB Auth do storage account
resource "azapi_update_resource" "storage_smb_oauth" {
  type        = "Microsoft.Storage/storageAccounts@2025-01-01"
  resource_id = azurerm_storage_account.sa-files.id

  body = {
    properties = {
      azureFilesIdentityBasedAuthentication = {
        directoryServiceOptions = "None"
        smbOAuthSettings = {
          isSmbOAuthEnabled = true
        }
      }
    }
  }
}
# Dar permissão IAM para o Identity da vm da australia
resource "azurerm_role_assignment" "windows_azure_files_iam" {
  scope                = azurerm_storage_account.sa-files.id
  role_definition_name = "Storage File Data SMB Share Contributor" # privilegio muito alto -> "Storage File Data SMB MI Admin"
  principal_id         = azurerm_windows_virtual_machine.windows["servers_australia"].identity[0].principal_id

  skip_service_principal_aad_check = true
}