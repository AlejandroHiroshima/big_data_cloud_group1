resource "azurerm_resource_group" "storage_rg" {
  name     = "rg-grupp1-terraform"
  location = var.location
}

# 1.Den första är terraofrm-resursens lokala namn. 
# 2. Är resursens faktiska namn.