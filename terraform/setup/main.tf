terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "terraform-state" {
  name     = "fcg-terraform-state-rg"
  location = var.location

  tags = {
    Purpose   = "Terraform State"
    ManagedBy = "terraform-setup"
  }
}

resource "azurerm_storage_account" "terraform-state" {
  name                     = "fcgterraformstate"
  resource_group_name      = azurerm_resource_group.terraform-state.name
  location                 = azurerm_resource_group.terraform-state.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  blob_properties {
    versioning_enabled = true
  }
}

resource "azurerm_storage_container" "terraform-state" {
  name                  = "terraform-state"
  storage_account_id    = azurerm_storage_account.terraform-state.id
  container_access_type = "private"
}
