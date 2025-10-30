# terraform {
#   required_providers {
#     azurerm = {
#       source  = "hashicorp/azurerm"
#       version = "~> 4.4" 
#     }
#   }
#   required_version = "~> 1.12"
# }

# provider "azurerm" {
#   features {

#   }
# }

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.4"
    }
  }
  required_version = ">= 1.6"
}
 
provider "azurerm" {
  features {}
 
  subscription_id = "29a87bec-b199-436d-a319-1bc66a3a8c30" # byt ut mot din subscription ID
  # tenant_id       = ""
}

