resource "azurerm_resource_group" "arc_rg" {
  name     = "${var.prefix}-aks-rg"
  location = var.location
}

resource "azurerm_kubernetes_cluster" "arc_cluster" {
  name                  = "${var.prefix}-cluster"
  location              = azurerm_resource_group.arc_rg.location
  resource_group_name   = azurerm_resource_group.arc_rg.name
  dns_prefix            = "${var.prefix}-dns"

  default_node_pool {
    name = "${var.prefix}nodepool"
    node_count = 1
    vm_size = "Standard_D2_V2"
  }

  identity {
    type = "SystemAssigned"
  }
}