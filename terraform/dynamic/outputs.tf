output "app_service_name" {
  value = azurerm_linux_web_app.main.name
}

output "app_service_url" {
  value = "https://${azurerm_linux_web_app.main.default_hostname}"
}

output "storage_account_name" {
  value = azurerm_storage_account.main.name
}

output "storage_container_name" {
  value = azurerm_storage_container.photos.name
}

output "storage_blob_endpoint" {
  value = azurerm_storage_account.main.primary_blob_endpoint
}

output "function_app_name" {
  value = azurerm_linux_function_app.main.name
}

output "function_app_default_hostname" {
  value = azurerm_linux_function_app.main.default_hostname
}

output "resized_container_name" {
  value = azurerm_storage_container.photos_resized.name
}