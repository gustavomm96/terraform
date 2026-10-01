# Terraform Settings Block
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "5.7.0"
    }
    # Usado para gerar caracteres aleatorios
    random = {
      source  = "hashicorp/random"
      version = "3.9.1"
    }
    # azapi_update_resource serve para atualizar uma propriedade de um recurso que já é criado pelo AzureRM, sem criar outra Storage Account
    azapi = {
      source  = "Azure/azapi"
      version = "2.13.0"
    }
  }
}