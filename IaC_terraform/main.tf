terraform {
  required_version = ">= 1.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# ---------------- Variabler ----------------

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "swedencentral"
}

variable "prefix_app_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "grupp1-dashboard"
}

variable "owner" {
  description = "Owner or team name"
  type        = string
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "profiles_local_path" {
  description = "Path to the local profiles.yml file (relative to this folder)"
  type        = string
  default     = "profiles.yml"
}

# ---------------- Lokala värden ----------------

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

locals {
  common_tags = {
    owner       = var.owner
    environment = "staging"
  }

  profiles_abs = "${path.module}/${var.profiles_local_path}"
}

# ---------------- Resurser ----------------

# Resource Group
resource "azurerm_resource_group" "storage_rg" {
  name     = "${var.prefix_app_name}-rg"
  location = var.location
  tags     = local.common_tags
}

# Storage Account
resource "azurerm_storage_account" "storage_terraform" {
  name                     = "stgrupp1tf${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.storage_rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.common_tags
}

# Azure File Share (namn: "files" för att undvika förväxling med data-mapp)
resource "azurerm_storage_share" "fileshare" {
  name                 = "files"
  storage_account_name = azurerm_storage_account.storage_terraform.name
  quota                = 3
  enabled_protocol     = "SMB"

  metadata = {
    env   = "staging"
    owner = var.owner
  }
}

# Katalog: .dbt (direkt i sharen, ingen "data" folder)
resource "azurerm_storage_share_directory" "dir_dbt" {
  name             = ".dbt"
  storage_share_id = azurerm_storage_share.fileshare.id
}

# Ladda upp profiles.yml till .dbt/profiles.yml
resource "azurerm_storage_share_file" "profiles" {
  storage_share_id = azurerm_storage_share.fileshare.id
  name             = ".dbt/profiles.yml"
  source           = local.profiles_abs

  depends_on = [azurerm_storage_share_directory.dir_dbt]
}

# Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = "acrgrupp1${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.storage_rg.name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true
  tags                = local.common_tags
}

# App Service Plan (Linux)
resource "azurerm_service_plan" "asp" {
  name                = "${var.prefix_app_name}-asp"
  location            = var.location
  resource_group_name = azurerm_resource_group.storage_rg.name
  sku_name            = "S1"
  os_type             = "Linux"
  tags                = local.common_tags
}

# Linux Web App med Docker från ACR och Azure Files mount
resource "azurerm_linux_web_app" "app" {
  name                = "${var.prefix_app_name}-app${random_string.suffix.result}"
  location            = var.location
  resource_group_name = azurerm_resource_group.storage_rg.name
  service_plan_id     = azurerm_service_plan.asp.id

  site_config {
    always_on  = true
    ftps_state = "Disabled"

    application_stack {
      docker_image_name        = "${azurerm_container_registry.acr.login_server}/dashboard:latest"
      docker_registry_username = azurerm_container_registry.acr.admin_username
      docker_registry_password = azurerm_container_registry.acr.admin_password
    }
  }

  storage_account {
    name         = "duckdbmount"
    type         = "AzureFiles"
    account_name = azurerm_storage_account.storage_terraform.name
    access_key   = azurerm_storage_account.storage_terraform.primary_access_key
    share_name   = azurerm_storage_share.fileshare.name  # = "files"
    mount_path   = "/mnt/data"
  }

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    WEBSITES_PORT                       = "8501"
    DBT_PROFILES_DIR                    = "/mnt/data/.dbt"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags

  depends_on = [
    azurerm_container_registry.acr,
    azurerm_storage_share_file.profiles
  ]
}

# ---------------- Outputs ----------------

output "resource_group_name" {
  description = "Resource group name"
  value       = azurerm_resource_group.storage_rg.name
}

output "storage_account_name" {
  description = "Storage account name"
  value       = azurerm_storage_account.storage_terraform.name
}

output "acr_name" {
  description = "Azure Container Registry name"
  value       = azurerm_container_registry.acr.name
}

output "acr_login_server" {
  description = "ACR login server"
  value       = azurerm_container_registry.acr.login_server
}

output "acr_admin_username" {
  description = "ACR admin username"
  value       = azurerm_container_registry.acr.admin_username
}

output "acr_admin_password" {
  description = "ACR admin password"
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
}

output "web_app_name" {
  description = "Web App name"
  value       = azurerm_linux_web_app.app.name
}

output "web_app_url" {
  description = "Web App default URL"
  value       = "https://${azurerm_linux_web_app.app.default_hostname}"
}