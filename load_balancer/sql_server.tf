resource "azurerm_mssql_server" "az_lb_sql_server" {
  name                          = var.sql_server_name
  resource_group_name           = azurerm_resource_group.az_rg.name
  location                      = var.location
  version                       = "12.0"
  administrator_login           = var.sql_admin
  administrator_login_password  = var.sql_password
  public_network_access_enabled = false

  tags = var.tags
}

resource "azurerm_mssql_database" "az_lb_sql_db" {
  name                 = var.sql_server_db
  server_id            = azurerm_mssql_server.az_lb_sql_server.id
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  license_type         = "LicenseIncluded"
  max_size_gb          = 1
  sku_name             = "S0"
  storage_account_type = "Zone"

  tags = var.tags
}

resource "azurerm_private_endpoint" "az_lb_sql_server_ep" {
  name                = "terralbsqlep"
  location            = var.location
  resource_group_name = azurerm_resource_group.az_rg.name
  subnet_id           = azurerm_subnet.lb_subnet.id

  private_service_connection {
    name                           = "terra-lb-sql-con"
    private_connection_resource_id = azurerm_mssql_server.az_lb_sql_server.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }
}
