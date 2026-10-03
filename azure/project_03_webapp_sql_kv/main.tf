module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.4"
  suffix  = ["gmapp"]
}

resource "random_string" "random" {
  length  = 5
  special = false
  upper   = false
}