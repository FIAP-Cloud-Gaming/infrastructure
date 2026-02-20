terraform {
  required_version = ">= 1.14.0"

  backend "azurerm" {
    resource_group_name  = "fcg-terraform-state-rg"
    storage_account_name = "fcgterraformstate"
    container_name       = "terraform-state"
    key                  = "vm.terraform.terraform-state"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}