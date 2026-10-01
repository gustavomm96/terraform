locals {
  common_tags = {
    source = "terraform"
    owner  = "gustavo"
    type   = "project02-fileshare"
  }
  # VMs windows bloco para usar o for_each
  windows_vms = {
    jumphost_canada = {
      name          = "vm-jumphost-cae-01"
      computer_name = "jump-cae-01" # Precisou alterar nome que o windows suporta no maximo 15 caracter para nome de maquina dentro do windows
      location      = azurerm_resource_group.rg-cae.location
      rg_name       = azurerm_resource_group.rg-cae.name
      subnet_id     = azurerm_subnet.snet1-cae.id
    }

    servers_australia = {
      name          = "vm-win-aue-01"
      computer_name = "server-aue-01"
      location      = azurerm_resource_group.rg-aue.location
      rg_name       = azurerm_resource_group.rg-aue.name
      subnet_id     = azurerm_subnet.snet1-aue.id
    }
  }

}


