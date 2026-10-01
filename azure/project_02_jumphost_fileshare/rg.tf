# RG Australia East
resource "azurerm_resource_group" "rg-aue" {
  name     = "rg-${var.project_name}-aue-01"
  location = var.workload_location
  tags     = local.common_tags
}

# RG Canada East
resource "azurerm_resource_group" "rg-cae" {
  name     = "rg-${var.project_name}-cae-01"
  location = var.jump_location
  tags     = local.common_tags
}