module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.4"
  suffix  = [var.project_name]
}

resource "random_string" "random" {
  length  = 5
  special = false
  upper   = false
}