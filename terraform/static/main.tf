terraform {
    required_providers {
      azurerm = {
        source = "hashicorp/azurerm"
        version = "~> 3.0"
      }
    }
}

provider "azurerm" {
    features {}
    skip_provider_registration = true
}

resource "azurerm_resource_group" "main" {
    name     = var.resource_group_name
    location = var.location
}

resource "azurerm_storage_account" "tfstate" {
    name                     = var.storage_account_name
    resource_group_name      = azurerm_resource_group.main.name
    location                 = azurerm_resource_group.main.location
    account_tier             = "Standard"
    account_replication_type = "LRS"

    blob_properties {
    versioning_enabled = true
}
}


resource "azurerm_storage_container" "tfstate" {
    name                  = "tfstate"
    storage_account_name  = azurerm_storage_account.tfstate.name
    container_access_type = "private"
}