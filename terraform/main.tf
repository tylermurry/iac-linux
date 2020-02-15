variable "client_id"       {}
variable "client_secret"   {}
variable "tenant_id"       {}
variable "subscription_id" {}
variable "vm_username"     {}
variable "vm_password"     {}

variable "vm_size"                { default = "Standard_B1ls" }
variable "vm_disk_type"           { default = "Standard_LRS" }
variable "prefix"                 { default = "iac-linux" }
variable "region"                 { default = "westus2" }
variable "networkd_address_space" { default = "1.0.0.0/22" }
variable "subnet_prefix"          { default = "1.0.1.0/24" }

provider "azurerm" {
  version         = "1.27"
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "rg" {
  location = var.region
  name     = "${var.prefix}-rg"
}

##############
# Networking #
##############

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.networkd_address_space]
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefix       = var.subnet_prefix
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_public_ip" "publicip" {
  name                 = "${var.prefix}-public-ip"
  resource_group_name  = azurerm_resource_group.rg.name
  location             = var.region
  allocation_method    = "Dynamic"
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-nsg"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.region

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic" {
  name                      = "${var.prefix}-nic"
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = var.region
  network_security_group_id = azurerm_network_security_group.nsg.id

  ip_configuration {
    name                          = "${var.prefix}-nic-ip-config"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

data "azurerm_public_ip" "data_publicip" {
  name                = azurerm_public_ip.publicip.name
  resource_group_name = azurerm_resource_group.rg.name
}

output "public_ip" {
  value       = azurerm_public_ip.publicip.ip_address
  description = "The private IP address of the main server instance."
}

####################
# Virtual Machines #
####################

resource "azurerm_virtual_machine" "vm" {
  name                  = "${var.prefix}-vm"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = var.region
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = var.vm_size

  storage_os_disk {
    name              = "${var.prefix}-os-disk"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = var.vm_disk_type
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.5"
    version   = "latest"
  }

  os_profile {
    computer_name  = "${var.prefix}-vm"
    admin_username = var.vm_username
    admin_password = var.vm_password
  }
}
