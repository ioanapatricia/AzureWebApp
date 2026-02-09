output "app_service_name" {
  value = azurerm_linux_web_app.main.name
}

output "app_service_url" {
  value = "https://${azurerm_linux_web_app.main.default_hostname}"
}