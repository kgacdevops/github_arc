resource "azurerm_resource_group" "arc_rg" {
  name     = "${var.prefix}-aks-rg"
  location = var.location
}