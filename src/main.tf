resource "azurerm_resource_group" "boster_web" {
  name     = TF_VAR_RG_NAME
  location = TF_VAR_RG_LOCATION
}