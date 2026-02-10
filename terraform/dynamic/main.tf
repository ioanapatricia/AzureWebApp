terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "test"
    storage_account_name = "tfstateazurewebapp"
    container_name       = "tfstate"
    key                  = "app.tfstate"
  }
}

provider "azurerm" {
    features {}
    skip_provider_registration = true
}

data "azurerm_resource_group" "main" {
    name = var.resource_group_name
}

resource "azurerm_service_plan" "main" {
  name                = "${var.app_name}-plan"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "main" {
  name                = var.app_name
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id

  app_settings = {
    AZURESTORAGE__CONNECTIONSTRING = var.azure_storage_connection_string
  }

  site_config {
    application_stack {
      dotnet_version = "8.0"
    }
  }
}