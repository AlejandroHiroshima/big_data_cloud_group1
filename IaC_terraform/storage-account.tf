resource "azurerm_storage_account" "storage_terraform" {
  name                     = "stgrupp1tf${random_string.suffix.result}"
  account_tier             = "Standard"
  location                 = var.location
  resource_group_name      = azurerm_resource_group.storage_rg.name
  account_replication_type = "LRS"

  tags = { environment = "staging" }
}

resource "azurerm_storage_container" "duckdb_container" {
  name                  = "terraform-duckdb-container"
  storage_account_name  = azurerm_storage_account.storage_terraform.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "upload_dukcdb" {
  name                   = "job_ads.duckdb"
  storage_account_name   = azurerm_storage_account.storage_terraform.name
  storage_container_name = azurerm_storage_container.duckdb_container.name
  type                   = "Block"
  source                 = "../duck_pond/job_ads.duckdb"
  content_type           = "application/octet-stream"
}
