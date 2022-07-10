terraform {
  required_version = ">= 1.1.0"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }
}

provider "azurerm" {
  features {}
}

# Virtual Machine Resources

resource "azurerm_resource_group" "rg" {
  name     = "myTFResourceGroup"
  location = "westus2"
}
resource "azurerm_virtual_network" "prod-vnet" {
  name                = "prod-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = "myTFResourceGroup"
}

resource "azurerm_subnet" "main" {
  name                 = "servers"
  resource_group_name  = "myTFResourceGroup"
  virtual_network_name = "prod-vnet"
  address_prefixes       = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "main-nic" {
  name                = "example-nic"
  location            = var.location
  resource_group_name = "myTFResourceGroup"

  ip_configuration {
    name                          = "example-ip"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface" "main2-nic" {
  name                = "example2-nic"
  location            = var.location
  resource_group_name = "myTFResourceGroup"

  ip_configuration {
    name                          = "example-ip"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface" "main3-nic" {
  name                = "example3-nic"
  location            = var.location
  resource_group_name = "myTFResourceGroup"

  ip_configuration {
    name                          = "example-ip"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "main" {
  name                = "DC1"
  resource_group_name = "myTFResourceGroup"
  location            = var.location
  size                = "Standard_B2ms"
  admin_username      = "adminuser"
  admin_password      = "P@ssw0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.main-nic.id,
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
}
resource "azurerm_windows_virtual_machine" "main2" {
  name                = "DC2"
  resource_group_name = "myTFResourceGroup"
  location            = var.location
  size                = "Standard_B2ms"
  admin_username      = "adminuser"
  admin_password      = "P@ssw0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.main2-nic.id,
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
}
resource "azurerm_windows_virtual_machine" "main3" {
  name                = "VM3"
  resource_group_name = "myTFResourceGroup"
  location            = var.location
  size                = "Standard_B2ms"
  admin_username      = "adminuser"
  admin_password      = "P@ssw0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.main3-nic.id,
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
}

resource "azurerm_virtual_machine_extension" "example" {
  name                 = "ansible_windows_winrm"
  virtual_machine_id   = azurerm_windows_virtual_machine.main.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = <<SETTINGS
    {
        "fileUris": ["https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"],
        "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file ConfigureRemotingForAnsible.ps1 -EnableCredSSP -DisableBasicAuth"
    }
SETTINGS
}

