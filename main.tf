resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}

data "azuread_client_config" "current" {}

resource "azuread_application" "aks-app" {
  display_name = "aks-app"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "aks-spn" {
  client_id                    = azuread_application.aks-app.client_id
  app_role_assignment_required = true
  owners                       = [data.azuread_client_config.current.object_id]
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "akscluster"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Aks-Production"    
  }
}

