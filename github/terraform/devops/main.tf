terraform {
  required_version = ">=0.13"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }

  }

  backend "azurerm" {
    container_name       = "<container-name in the storage account>"
    key                  = "<state file key>"
    storage_account_name = "storage account name for tf state"
  }

}

provider "azurerm" {
  features {}

  subscription_id = local.subscription_id
  tenant_id       = local.tenant_id
}
