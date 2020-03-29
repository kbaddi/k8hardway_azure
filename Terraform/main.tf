provider "azurerm" {
  version         = "~>2.1"
    features {
  }
}


# Resource Group to provision resources.

resource "azurerm_resource_group" "k8hway" {
  name     = "${var.prefix}-RG"
  location = var.location
  tags     = var.tags
}