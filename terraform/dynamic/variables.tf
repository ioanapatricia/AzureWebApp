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

variable "storage_account_name" {
  description = "Name of the Storage Account (must be globally unique, lowercase, 3-24 characters)"
  type        = string
  default     = "sadevazurewebapp"
}

variable "function_app_name" {
  description = "Name of the Function App (must be globally unique)"
  type        = string
  default     = "azurewebapp-demo-function"
}

variable "image_resize_width" {
  description = "Width for resized images"
  type        = string
  default     = "500"
}

variable "image_resize_height" {
  description = "Height for resized images"
  type        = string
  default     = "500"
}

variable "image_resize_quality" {
  description = "Quality for resized images"
  type        = string
  default     = "90"
}

variable "sql_server_name" {
  description = "Name of the SQL Server (must be globally unique)"
  type        = string
  default     = "azurewebapp-sqlserver"
}

variable "sql_database_name" {
  description = "Name of the SQL Database"
  type        = string
  default     = "azurewebapp-db"
}

variable "sql_admin_username" {
  description = "SQL Server administrator username"
  type        = string
  sensitive   = true
}

variable "sql_admin_password" {
  description = "SQL Server administrator password"
  type        = string
  sensitive   = true
}