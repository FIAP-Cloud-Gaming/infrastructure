terraform {
  required_version = ">= 1.14.0"

  backend "azurerm" {
    resource_group_name  = "fcg-tfstate-rg"
    storage_account_name = "fcgtfstate"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }

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
