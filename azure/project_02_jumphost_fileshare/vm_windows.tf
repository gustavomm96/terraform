# Criar PIP para canada vm
resource "azurerm_public_ip" "jump_canada" {
  name                = "pip-jumphost-cae-01"
  location            = azurerm_resource_group.rg-cae.location
  resource_group_name = azurerm_resource_group.rg-cae.name

  allocation_method = "Static"
  sku               = "Standard"

  tags = local.common_tags
}

resource "azurerm_network_interface" "windows" {
  for_each = local.windows_vms # Faz um laço com os dados de 2 vms que coloquei no locals

  name                = "nic-${each.value.name}"
  location            = each.value.location
  resource_group_name = each.value.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = "Dynamic"

    # É um condição ternaria do terraform, so vai adicionar pip para a vm jump host do canada as outras não vai ser feito nada por isso do : null
    public_ip_address_id = (
      each.key == "jumphost_canada"
      ? azurerm_public_ip.jump_canada.id
      : null
    )
  }

  tags = local.common_tags
}

resource "azurerm_windows_virtual_machine" "windows" {
  for_each = local.windows_vms # Faz um laço passando as informações das vms

  name                = each.value.name
  computer_name       = each.value.computer_name
  resource_group_name = each.value.rg_name
  location            = each.value.location
  size                = var.vm_size

  admin_username = var.admin_username
  admin_password = var.windows_admin_password

  network_interface_ids = [
    azurerm_network_interface.windows[each.key].id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }
  # Vai ativar apenas nas vms servers da australia, não vai ser feito no jump host do canada
  # o [1] não é uma quantidade de VMs nem um ID: é apenas um elemento para gerar um bloco. A lista [] gera zero blocos.
  dynamic "identity" {
    for_each = each.key == "servers_australia" ? [1] : []

    content {
      type = "SystemAssigned"
    }
  }

  tags = merge(local.common_tags, {
    role = each.key
    os   = "windows"
  })
}

# Mapeamento do file share
resource "azurerm_virtual_machine_extension" "windows_files_prepare" {
  name                 = "prepare-azure-files"
  virtual_machine_id   = azurerm_windows_virtual_machine.windows["servers_australia"].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  # vai criar um arquivo txt C:\AzureFilesLab\share-path.txt com o caminho do file share comprando a conexão TCP da porta 445
  settings = jsonencode({
    commandToExecute = <<-CMD
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$hostName='${azurerm_storage_account.sa-files.name}.file.core.windows.net'; $share='${azurerm_storage_share.shared.name}'; if (-not (Test-NetConnection -ComputerName $hostName -Port 445 -InformationLevel Quiet)) { throw 'TCP 445 indisponivel' }; New-Item -ItemType Directory -Path 'C:\AzureFilesLab' -Force | Out-Null; Set-Content -Path 'C:\AzureFilesLab\share-path.txt' -Value ('\\' + $hostName + '\' + $share)"
    CMD
  })
}
