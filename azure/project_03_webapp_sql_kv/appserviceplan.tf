# App Service Plan - Linux
resource "azurerm_service_plan" "asp-linux" {
  name                = "asp-${var.project_name}-01"
  location            = azurerm_resource_group.rg-gmapp.location
  resource_group_name = azurerm_resource_group.rg-gmapp.name
  os_type             = "Linux"
  sku_name            = "F1" # free tier

  tags = local.common_tags
}