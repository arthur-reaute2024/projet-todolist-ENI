terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.41.0"
    }
    ovh = {
      source  = "ovh/ovh"
      version = "~> 2.7"
    }
  }
}
provider "azurerm" {
  subscription_id = "ca5c57dd-3aab-4628-a78c-978830d03bbd"
  features {}
}

provider "ovh" {
  endpoint           = "ovh-eu"
  application_key    = var.ovh_application_key
  application_secret = var.ovh_application_secret
  consumer_key       = var.ovh_consumer_key
}
