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

resource "azurerm_network_interface" "lb_vm_nic_1" {
  name                = "lb_vm_nic_1"
  location            = var.location
  resource_group_name = azurerm_resource_group.az_rg.name

  ip_configuration {
    name                          = "lb_vm_nic_1"
    subnet_id                     = azurerm_subnet.lb_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "lb_vm_nic_1" {
  network_interface_id      = azurerm_network_interface.lb_vm_nic_1.id
  network_security_group_id = azurerm_network_security_group.lb_vm_nsg.id
}

resource "azurerm_network_interface" "lb_vm_nic_2" {
  name                = "lb_vm_nic_2"
  location            = var.location
  resource_group_name = azurerm_resource_group.az_rg.name

  ip_configuration {
    name                          = "lb_vm_nic_2"
    subnet_id                     = azurerm_subnet.lb_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "lb_vm_nic_2" {
  network_interface_id      = azurerm_network_interface.lb_vm_nic_2.id
  network_security_group_id = azurerm_network_security_group.lb_vm_nsg.id
}

resource "azurerm_network_interface" "lb_vm_nic_3" {
  name                = "lb_vm_nic_3"
  location            = var.location
  resource_group_name = azurerm_resource_group.az_rg.name

  ip_configuration {
    name                          = "lb_vm_nic_3"
    subnet_id                     = azurerm_subnet.lb_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "lb_vm_nic_3" {
  network_interface_id      = azurerm_network_interface.lb_vm_nic_3.id
  network_security_group_id = azurerm_network_security_group.lb_vm_nsg.id
}

resource "tls_private_key" "lb_vm_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine" "lb_vm_1" {
  name                  = "${var.instance_name_prefix}1"
  location              = var.location
  resource_group_name   = azurerm_resource_group.az_rg.name
  network_interface_ids = [azurerm_network_interface.lb_vm_nic_1.id]
  size                  = "Standard_B1s"
  zone                  = "1"

  os_disk {
    name                 = "OsDiskVm1"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  computer_name                   = "${var.instance_name_prefix}1"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.lb_vm_key.public_key_openssh
  }

  boot_diagnostics {
  }
}

resource "azurerm_linux_virtual_machine" "lb_vm_2" {
  name                  = "${var.instance_name_prefix}2"
  location              = var.location
  resource_group_name   = azurerm_resource_group.az_rg.name
  network_interface_ids = [azurerm_network_interface.lb_vm_nic_2.id]
  size                  = "Standard_B1s"
  zone                  = "2"

  os_disk {
    name                 = "OsDiskVm2"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  computer_name                   = "${var.instance_name_prefix}2"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.lb_vm_key.public_key_openssh
  }

  boot_diagnostics {
  }
}

resource "azurerm_linux_virtual_machine" "lb_vm_3" {
  name                  = "${var.instance_name_prefix}3"
  location              = var.location
  resource_group_name   = azurerm_resource_group.az_rg.name
  network_interface_ids = [azurerm_network_interface.lb_vm_nic_3.id]
  size                  = "Standard_B1s"
  zone                  = "3"

  os_disk {
    name                 = "OsDiskVm3"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  computer_name                   = "${var.instance_name_prefix}3"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.lb_vm_key.public_key_openssh
  }

  boot_diagnostics {
  }
}

resource "azurerm_virtual_machine_extension" "install_apache_vm1" {
  name                 = "install-apache"
  virtual_machine_id   = azurerm_linux_virtual_machine.lb_vm_1.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  protected_settings = <<SETTINGS
  {
    "commandToExecute": "sudo apt update  \n      sudo apt install -y apache2 \n      sudo sed -i 's/80/0.0.0.0:80/g' /etc/apache2/ports.conf \n      echo `hostname` > /var/www/html/index.html \n      sudo systemctl enable apache2 \n      sudo systemctl start apache2"
  }
  SETTINGS
}

resource "azurerm_virtual_machine_extension" "install_apache_vm2" {
  name                 = "install-apache"
  virtual_machine_id   = azurerm_linux_virtual_machine.lb_vm_2.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  protected_settings = <<SETTINGS
  {
    "commandToExecute": "sudo apt update  \n      sudo apt install -y apache2 \n      sudo sed -i 's/80/0.0.0.0:80/g' /etc/apache2/ports.conf \n      echo `hostname` > /var/www/html/index.html \n      sudo systemctl enable apache2 \n      sudo systemctl start apache2"
  }
  SETTINGS
}

resource "azurerm_virtual_machine_extension" "install_apache_vm3" {
  name                 = "install-apache"
  virtual_machine_id   = azurerm_linux_virtual_machine.lb_vm_3.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  protected_settings = <<SETTINGS
  {
    "commandToExecute": "sudo apt update  \n      sudo apt install -y apache2 \n      sudo sed -i 's/80/0.0.0.0:80/g' /etc/apache2/ports.conf \n      echo `hostname` > /var/www/html/index.html \n      sudo systemctl enable apache2 \n      sudo systemctl start apache2"
  }
  SETTINGS
}
