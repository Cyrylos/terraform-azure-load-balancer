output "lb_public_ip_address" {
  value = azurerm_public_ip.az_lb_pub_ip[0]
}

output "tls_private_key" {
  value     = tls_private_key.lb_vm_key.private_key_pem
  sensitive = true
}