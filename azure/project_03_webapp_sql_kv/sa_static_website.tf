# Criar Storage account do site estatico
resource "azurerm_storage_account" "sa-site" {
  name                     = "sagmstatic${random_string.random.result}"
  resource_group_name      = azurerm_resource_group.rg-gmapp.name
  location                 = azurerm_resource_group.rg-gmapp.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false

  tags = local.common_tags
}
# Bloco para refenciar que o SA vai ser para site estático
resource "azurerm_storage_account_static_website" "static-website" {
  storage_account_id = azurerm_storage_account.sa-site.id
  index_document     = "index.html"
  error_404_document = "404.html"
}

# Subir os arquivos no blob
resource "azurerm_storage_blob" "static-website-files" {
  for_each = fileset("${path.module}/website", "**")

  name                 = each.value
  storage_container_id = "${azurerm_storage_account.sa-site.id}/blobServices/default/containers/$web"
  type                 = "Block"
  source               = "${path.module}/website/${each.value}"
  content_md5          = filemd5("${path.module}/website/${each.value}")
  content_type = lookup({
    html = "text/html; charset=utf-8"
    css  = "text/css; charset=utf-8"
    svg  = "image/svg+xml"
  }, lower(regex("[^.]+$", each.value)), "application/octet-stream")

  depends_on = [azurerm_storage_account_static_website.static-website]
}