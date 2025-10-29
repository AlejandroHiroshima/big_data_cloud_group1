# terraform {
#   backend "azurerm" {
#     resource_group_name  = "rg-grupp1-terraform"
#     storage_account_name = "stgrupp1tf3o5rc6"
#     container_name       = "tfstate-python-deploy"
#     key                  = "dev.terraform.tfstate"
#   }
# }