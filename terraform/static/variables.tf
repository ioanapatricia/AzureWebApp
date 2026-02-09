variable "resource_group_name" {
  description = "The name of the resource group in which to create the resources."
  type        = string
  default = "test"
}

variable "location" {
  description = "The location of the resource group."
  type        = string
  default = "Sweden Central"
}

variable "storage_account_name" {
  description = "The name of the storage account to create."
  type        = string
  default = "tfstateazurewebapp"
}