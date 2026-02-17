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

resource "azurerm_storage_account" "main" {
  name                     = var.storage_account_name
  resource_group_name      = data.azurerm_resource_group.main.name
  location                 = data.azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "photos" {
  name                  = "photos"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "blob"
}

resource "azurerm_storage_container" "photos_resized" {
  name                  = "photos-resized"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "blob"
}

resource "azurerm_service_plan" "main" {
  name                = "${var.app_name}-plan"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_service_plan" "function_plan" {
  name                = "${var.function_app_name}-plan"
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
    AZURESTORAGE__CONNECTIONSTRING = azurerm_storage_account.main.primary_blob_connection_string
    AZURESTORAGE__CONTAINERNAME    = "photos"
  }

  site_config {
    application_stack {
      dotnet_version = "8.0"
    }
  }
}

resource "azurerm_linux_function_app" "main" {
  name                       = var.function_app_name
  resource_group_name        = data.azurerm_resource_group.main.name
  location                   = data.azurerm_resource_group.main.location
  service_plan_id            = azurerm_service_plan.function_plan.id
  storage_account_name       = azurerm_storage_account.main.name
  storage_account_access_key = azurerm_storage_account.main.primary_access_key

  app_settings = {
    # Required Azure Functions settings
    "AzureWebJobsStorage"                = azurerm_storage_account.main.primary_connection_string
    "FUNCTIONS_WORKER_RUNTIME"           = "dotnet-isolated"
    "FUNCTIONS_EXTENSION_VERSION"        = "~4"
    
    # Application configuration
    "AzureStorageConnection"            = azurerm_storage_account.main.primary_blob_connection_string
    "AzureStorage__ConnectionString"    = azurerm_storage_account.main.primary_blob_connection_string
    "AzureStorage__ResizedContainer"    = azurerm_storage_container.photos_resized.name
    "ImageResize__Width"                = var.image_resize_width
    "ImageResize__Height"               = var.image_resize_height
    "ImageResize__Quality"              = var.image_resize_quality
  }

  site_config {
    application_stack {
      dotnet_version              = "8.0"
      use_dotnet_isolated_runtime = true
    }
  }
}