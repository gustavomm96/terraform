# RG
resource "azurerm_resource_group" "rg-gmlabs" {
  name     = "rg-gmlabs"
  location = "canadaeast"
  tags     = local.common_tags
}
