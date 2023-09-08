terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.64.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  subscription_id = "1c986024-61ee-47c0-937b-ebddd96c0e3c"
  client_id       = "87e4960b-38db-4217-adc7-a7a954425076"
  client_secret   = "CSu8Q~iTNozHGxufXsBlTyQG1kkLxcVsEUbgea8L"
  tenant_id       = "e193cd8b-a9aa-46d9-9b09-f14d5fede4dd"
  features {}
}

variable "azurerm_resource_group" {
  type = string
  description = "Enter the name of resource group:"
}

locals {
  resource_group = "csi-neu-acr-dev"
  location = "North Europe"
}

resource "azurerm_resource_group" "app_grp" {
  name     = var.azurerm_resource_group
  location = local.location
}

resource "azurerm_storage_account" "storage_account1" {
  name                     = "csistoragetest2023"
  resource_group_name      = azurerm_resource_group.app_grp.name
  location                 = azurerm_resource_group.app_grp.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  # This means that only after the creation of the resource group can this take place
  depends_on = [ 
    azurerm_resource_group.app_grp
   ]
}

resource "azurerm_network_security_group" "nsg1" {
  name                = "csi-security-group"
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name
}

resource "azurerm_virtual_network" "vnet" {
  name                = "csi-app-network"
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "subnet2"
    address_prefix = "10.0.2.0/24"
    security_group = azurerm_network_security_group.nsg1.id
  }

  tags = {
    environment = "Test"
  }
}

# To get information on existing resource we use the data block
data "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.app_grp.name
}

resource "azurerm_network_interface" "app_interface" {
  name                = "csi-app-nic"
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [ 
    azurerm_virtual_network.vnet
   ]
}

resource "azurerm_windows_virtual_machine" "main_virtual_vm" {
  name                = "csi-main-win-vm"
  resource_group_name = azurerm_resource_group.app_grp.name
  location            = azurerm_resource_group.app_grp.location
  size                = "Standard_B4ms"
  admin_username      = "GAF2KOR"
  admin_password      = "PythonBOSCH@2022!"
  network_interface_ids = [
    azurerm_network_interface.app_interface.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  depends_on = [ 
    azurerm_network_interface.app_interface 
    ]
}
