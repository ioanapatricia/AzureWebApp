variable "resource_group_name" {
  description = "The name of the resource group in which to create the resources."
  type        = string
  default     = "test"
}

variable "app_name" {
  description = "Name of the App Service (must be globally unique)"
  type        = string
  default     = "azurewebapp-demo"
}

variable "azure_storage_connection_string" {
  description = "Connection string for Azure Storage Account"
  type        = string
  sensitive   = true
}