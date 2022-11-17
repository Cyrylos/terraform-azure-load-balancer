resource "azurerm_network_interface" "lb_vm_nic" {
  name                = "lb_vm_nic_1"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "lb_vm_nic_1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "lb_vm_nic_nsg" {
  network_interface_id      = azurerm_network_interface.lb_vm_nic.id
  network_security_group_id = var.nsg_id
}

resource "azurerm_linux_virtual_machine" "lb_vm" {
  name                  = var.instance_name
  location              = var.location
  resource_group_name   = var.resource_group
  network_interface_ids = [azurerm_network_interface.lb_vm_nic.id]
  size                  = "Standard_B1s"
  zone                  = "1"

  os_disk {
    name                 = "OsDisk${var.instance_name}"
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

resource "azurerm_virtual_machine_extension" "install_apache" {
  name                 = "install-apache"
  virtual_machine_id   = azurerm_linux_virtual_machine.lb_vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  protected_settings = <<SETTINGS
  {
    "commandToExecute": "sudo apt update  \n      sudo apt install -y apache2 \n      sudo sed -i 's/80/0.0.0.0:80/g' /etc/apache2/ports.conf \n      echo `hostname` > /var/www/html/index.html \n      sudo systemctl enable apache2 \n      sudo systemctl start apache2"
  }
  SETTINGS
}