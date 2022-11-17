output "nic_id" {
  value = azurerm_network_interface.lb_vm_nic.id
}
output "vm_id" {
  value = azurerm_linux_virtual_machine.lb_vm.id
}