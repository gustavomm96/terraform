# Create Network Internface - NICs
# NIC01
resource "azurerm_network_interface" "nic-vm-nginx-01" {
  name                = "${module.naming.network_interface.name}-01"
  location            = azurerm_resource_group.rg-gmlabs.location
  resource_group_name = azurerm_resource_group.rg-gmlabs.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

# NIC02
resource "azurerm_network_interface" "nic-vm-nginx-02" {
  name                = "${module.naming.network_interface.name}-02" # O nome precisa ser assim, porque o modulo naming gera um nome unico por chamada e sempre vai usar ele, se não deixar assim ele vai colar 2 recursos com o mesmo nome e vai bater
  location            = azurerm_resource_group.rg-gmlabs.location
  resource_group_name = azurerm_resource_group.rg-gmlabs.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet2.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create Virtual Machine Linux
# VM-01 nginx
resource "azurerm_virtual_machine" "vm-nginx-01" {
  name                  = "vm-nginx-01"
  location              = azurerm_resource_group.rg-gmlabs.location
  resource_group_name   = azurerm_resource_group.rg-gmlabs.name
  network_interface_ids = [azurerm_network_interface.nic-vm-nginx-01.id]
  vm_size               = "Standard_B2ls_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${module.naming.managed_disk.name}-01"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "StandardSSD_LRS"
  }

  os_profile {
    computer_name  = "vm-nginx-01"
    admin_username = var.admin_user
    admin_password = var.admin_password
    custom_data    = file("${path.module}/cloud-init.yaml")
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  delete_os_disk_on_termination = true

  tags = merge(local.common_tags, {
    role = "WebServer"
  })

}

# Vm 02
resource "azurerm_virtual_machine" "vm-nginx-02" {
  name                  = "vm-nginx-02"
  location              = azurerm_resource_group.rg-gmlabs.location
  resource_group_name   = azurerm_resource_group.rg-gmlabs.name
  network_interface_ids = [azurerm_network_interface.nic-vm-nginx-02.id]
  vm_size               = "Standard_B2ls_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${module.naming.managed_disk.name}-02" # The name has to be like this because the naming module doesn't generate a unique name for each call and will always use that name; if you don't leave it like this, it will merge two resources with the same name, and they'll conflict.
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "StandardSSD_LRS"
  }

  os_profile {
    computer_name  = "vm-nginx-02"
    admin_username = "adminuser"
    admin_password = "Password12345!@AzTeste"
    custom_data    = file("${path.module}/cloud-init.yaml")
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  delete_os_disk_on_termination = true

  tags = merge(local.common_tags, {
    role = "WebServer"
  })

}

