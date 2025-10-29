resource "azurerm_resource_group" "storage_rg" {
  name     = "${var.prefix_app_name}-rg"
  location = var.location
}

