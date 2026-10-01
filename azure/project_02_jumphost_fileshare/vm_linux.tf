resource "azurerm_network_interface" "linux" {
  name                = "nic-vm-linux-aue-01"
  location            = azurerm_resource_group.rg-aue.location
  resource_group_name = azurerm_resource_group.rg-aue.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet1-aue.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = merge(local.common_tags, {
    os = "linux"
  })
}

resource "azurerm_linux_virtual_machine" "linux" {
  name                = "vm-linux-aue-01"
  computer_name       = "vm-linux-01"
  resource_group_name = azurerm_resource_group.rg-aue.name
  location            = azurerm_resource_group.rg-aue.location
  size                = var.vm_size

  admin_username                  = var.admin_username
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.linux.id
  ]
  # Configuração do ssh, envia a public key para a vm
  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.linux_ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  tags = merge(local.common_tags, {
    os = "linux"
  })
}