resource "azurerm_resource_group" "boster_web" {
  name     = var.resource_group_name
  location = var.resource_group_location
}