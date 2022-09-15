terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "terraform_group" {
  name     = "terraform_group"
  location = "southcentralus"
  tags = {
    enviroment = "Dev"
    source     = "Terraform"
    owner      = "Henry"
  }
}

resource "azurerm_virtual_network" "terraform_network" {
  name                = "terraform_network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.terraform_group.location
  resource_group_name = azurerm_resource_group.terraform_group.name
}

resource "azurerm_subnet" "terraform_subnet" {
  name                 = "terraform_subnet"
  resource_group_name  = azurerm_resource_group.terraform_group.name
  virtual_network_name = azurerm_virtual_network.terraform_network.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "terraform_net_interface" {
  name                = "terraform_interface"
  location            = azurerm_resource_group.terraform_group.location
  resource_group_name = azurerm_resource_group.terraform_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.terraform_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "terraform_linux_machine" {
  name                = "terraformlinuxmachine"
  resource_group_name = azurerm_resource_group.terraform_group.name
  location            = azurerm_resource_group.terraform_group.location
  size                = "Standard_F1"
  admin_username      = "adminuser"
  admin_password      = "92414244"
  network_interface_ids = [
    azurerm_network_interface.terraform_net_interface.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}