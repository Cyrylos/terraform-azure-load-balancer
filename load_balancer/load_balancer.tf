resource "azurerm_public_ip" "az_lb_pub_ip" {
  count               = 1
  name                = "terra_pub_ip"
  resource_group_name = azurerm_resource_group.az_rg.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_lb" "az_lb" {
  name                = var.lb_name
  resource_group_name = azurerm_resource_group.az_rg.name
  location            = var.location
  sku                 = "Standard"
  tags                = var.tags

  frontend_ip_configuration {
    name                 = var.frontend_name
    public_ip_address_id = azurerm_public_ip.az_lb_pub_ip[0].id
  }
}

resource "azurerm_lb_backend_address_pool" "az_lb_bap" {
  name            = "TerraLbBackend"
  loadbalancer_id = azurerm_lb.az_lb.id
}

resource "azurerm_lb_probe" "az_lb_hc" {
  name            = "terra-lb-hc"
  loadbalancer_id = azurerm_lb.az_lb.id
  protocol        = "Http"
  port            = 80
  request_path    = "/"
}

resource "azurerm_network_interface_backend_address_pool_association" "az_lb_bap_assoc1" {
  network_interface_id    = module.lb_vm_1.nic_id
  ip_configuration_name   = "lb_vm_nic_1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.az_lb_bap.id
}

resource "azurerm_network_interface_backend_address_pool_association" "az_lb_bap_assoc2" {
  network_interface_id    = module.lb_vm_2.nic_id
  ip_configuration_name   = "lb_vm_nic_2"
  backend_address_pool_id = azurerm_lb_backend_address_pool.az_lb_bap.id
}

resource "azurerm_network_interface_backend_address_pool_association" "az_lb_bap_assoc3" {
  network_interface_id    = module.lb_vm_3.nic_id
  ip_configuration_name   = "lb_vm_nic_3"
  backend_address_pool_id = azurerm_lb_backend_address_pool.az_lb_bap.id
}

resource "azurerm_lb_rule" "az_lb_rule" {
  name                           = "hhtpFront"
  loadbalancer_id                = azurerm_lb.az_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = var.frontend_name
  enable_floating_ip             = false
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.az_lb_bap.id]
  idle_timeout_in_minutes        = 5
  probe_id                       = azurerm_lb_probe.az_lb_hc.id
  disable_outbound_snat          = true
}

resource "azurerm_lb_outbound_rule" "az_lb_out_rule" {
  name                    = "NatInternetAccess"
  loadbalancer_id         = azurerm_lb.az_lb.id
  protocol                = "All"
  backend_address_pool_id = azurerm_lb_backend_address_pool.az_lb_bap.id

  frontend_ip_configuration {
    name = var.lb_name
  }
}