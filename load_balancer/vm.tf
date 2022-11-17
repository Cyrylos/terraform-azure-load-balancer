resource "azurerm_virtual_network" "lb_vn" {
  name                = "myVnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.az_rg.name
}

resource "azurerm_subnet" "lb_subnet" {
  name                 = "terra-lb-test"
  resource_group_name  = azurerm_resource_group.az_rg.name
  virtual_network_name = azurerm_virtual_network.lb_vn.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "lb_vm_nsg" {
  name                = "TerraLbNSG"
  location            = var.location
  resource_group_name = azurerm_resource_group.az_rg.name

  security_rule {
    name                       = "HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "tls_private_key" "lb_vm_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

module "lb_vm_1" {
  source = "../modules/vm"

  location       = var.location
  resource_group = azurerm_resource_group.az_rg.name
  subnet_id      = azurerm_subnet.lb_subnet.id
  nsg_id         = azurerm_network_security_group.lb_vm_nsg.id
  instance_type  = var.instance_type
  instance_name  = "${var.instance_name_prefix}1"
  nic_name       = "lb_vm_nic_1"
  zone           = "1"
  pub_vm_key     = tls_private_key.lb_vm_key.public_key_openssh
}

module "lb_vm_2" {
  source = "../modules/vm"

  location       = var.location
  resource_group = azurerm_resource_group.az_rg.name
  subnet_id      = azurerm_subnet.lb_subnet.id
  nsg_id         = azurerm_network_security_group.lb_vm_nsg.id
  instance_type  = var.instance_type
  instance_name  = "${var.instance_name_prefix}2"
  nic_name       = "lb_vm_nic_2"
  zone           = "2"
  pub_vm_key     = tls_private_key.lb_vm_key.public_key_openssh
}

module "lb_vm_3" {
  source = "../modules/vm"

  location       = var.location
  resource_group = azurerm_resource_group.az_rg.name
  subnet_id      = azurerm_subnet.lb_subnet.id
  nsg_id         = azurerm_network_security_group.lb_vm_nsg.id
  instance_type  = var.instance_type
  instance_name  = "${var.instance_name_prefix}3"
  nic_name       = "lb_vm_nic_3"
  zone           = "3"
  pub_vm_key     = tls_private_key.lb_vm_key.public_key_openssh
}