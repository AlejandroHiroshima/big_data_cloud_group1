# Storage Account
resource "azurerm_storage_account" "storage_terraform" {
  name                     = "stgrupp1tf${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.storage_rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = { environment = "staging" }
}

# Azure File Share
resource "azurerm_storage_share" "fileshare" {
  name                 = "data"
  storage_account_name = azurerm_storage_account.storage_terraform.name
  quota                = 3
  enabled_protocol     = "SMB"
  metadata = {
    env = "staging"
  }
}

