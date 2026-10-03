# RG KV Australia East
resource "azurerm_resource_group" "rg-kv-aue" {
  name     = "rg-kv-${var.project_name}-01"
  location = var.project_location
  tags     = local.common_tags
}

# RG WebApp Australia East
resource "azurerm_resource_group" "rg-gmapp" {
  name     = "rg-${var.project_name}-01"
  location = var.project_location
  tags     = local.common_tags
}