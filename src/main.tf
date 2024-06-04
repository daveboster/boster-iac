resource "azurerm_resource_group" "boster_web" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

data "azuread_client_config" "newrelic_client_config" {}
data "azurerm_subscription" "newrelic_subscription" {}
data "azuread_application_published_app_ids" "well_known" {}

# https://github.com/newrelic/terraform-provider-newrelic/blob/main/examples/modules/cloud-integrations/azure/main.tf
resource "azuread_service_principal" "msgraph" {
  application_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
  use_existing   = true
}

resource "azuread_application" "newrelic_application" {
  display_name     = "NewRelic-Integrations"
  # owners           = [data.azuread_client_config.newrelic_client_config.object_id]
  sign_in_audience = "AzureADMyOrg"

  web {
    redirect_uris = ["https://www.newrelic.com/"]
  }
}

resource "azuread_service_principal" "newrelic_service_principal" {
  application_id = azuread_application.newrelic_application.application_id
}

resource "azurerm_role_assignment" "newrelic_role_assignment" {
  scope                = data.azurerm_subscription.newrelic_subscription.id
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.newrelic_service_principal.object_id
}

resource "azuread_application_password" "newrelic_application_password" {
  application_object_id = azuread_application.newrelic_application.object_id
}

resource "newrelic_cloud_azure_link_account" "newrelic_cloud_azure_integration" {
  account_id      = var.newrelic_account_id
  application_id  = azuread_application.newrelic_application.application_id
  client_secret   = azuread_application_password.newrelic_application_password.value
  subscription_id = data.azurerm_subscription.newrelic_subscription.subscription_id
  tenant_id       = data.azurerm_subscription.newrelic_subscription.tenant_id
  name            = var.newrelic_application_name

  depends_on = [
    azurerm_role_assignment.newrelic_role_assignment
  ]
} 

# https://github.com/newrelic/terraform-provider-newrelic/blob/main/examples/modules/cloud-integrations/azure/main.tf
# https://docs.newrelic.com/docs/infrastructure/microsoft-azure-integrations/azure-integrations-list/azure-monitor/#migrate
resource "newrelic_cloud_azure_integrations" "newrelic_cloud_azure_integration" {
  linked_account_id = newrelic_cloud_azure_link_account.newrelic_cloud_azure_integration.id
  account_id = var.newrelic_account_id

  monitor {
    metrics_polling_interval = 60
    resource_groups          = [ azurerm_resource_group.boster_web.name ]
    enabled                  = true
  }
}