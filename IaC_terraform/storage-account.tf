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

# Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = "acrgrupp1${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.storage_rg.name
  location            = var.location
  sku                 = "Basic"  # Basic, Standard eller Premium
  admin_enabled       = true     # Aktiverar admin-användare (bra för dev/test)

  tags = { environment = "staging" }
}

# (Valfritt) Output för att se login-server och admin-credentials
output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "acr_admin_username" {
  value = azurerm_container_registry.acr.admin_username
}

output "acr_admin_password" {
  value     = azurerm_container_registry.acr.admin_password
  sensitive = true
}