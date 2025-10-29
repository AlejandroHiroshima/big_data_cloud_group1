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
  name               = "data"
  storage_account_id = azurerm_storage_account.storage_terraform.id
  quota              = 3
  enabled_protocol   = "SMB"
  metadata = {
    env = "staging"
  }
}

# Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = "acrgrupp1${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.storage_rg.name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true
  tags                = { environment = "staging" }
}

# App Service Plan (Linux)
resource "azurerm_service_plan" "asp" {
  name                = "${var.prefix_app_name}-asp"
  location            = var.location
  resource_group_name = azurerm_resource_group.storage_rg.name
  sku_name            = "S1" # inte 'sku'
  os_type             = "Linux"
}

# Linux Web App som kör container från ACR
resource "azurerm_linux_web_app" "app" {
  name                = "${var.prefix_app_name}-app${random_string.suffix.result}"
  location            = var.location
  resource_group_name = azurerm_resource_group.storage_rg.name
  service_plan_id     = azurerm_service_plan.asp.id

  site_config {
    application_stack {
      docker_registry_url      = "https://${azurerm_container_registry.acr.login_server}"
      docker_image_name        = "${var.prefix_app_name}:latest"
      docker_registry_username = azurerm_container_registry.acr.admin_username
      docker_registry_password = azurerm_container_registry.acr.admin_password
    }
  }

  storage_account {
    name         = "duckdbmount"
    type         = "AzureFiles"
    account_name = azurerm_storage_account.storage_terraform.name
    access_key   = azurerm_storage_account.storage_terraform.primary_access_key
    share_name   = azurerm_storage_share.fileshare.name
    mount_path   = "/mnt/data"
  }

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    WEBSITES_PORT                       = "8501"
  }

  identity { type = "SystemAssigned" }
  tags = { environment = "staging" }

  depends_on = [azurerm_container_registry.acr]
}

# Outputs
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
