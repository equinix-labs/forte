provider "equinix" {
  client_id     = var.equinix_client_id
  client_secret = var.equinix_client_secret
}

provider "azurerm" {
  features {}

  subscription_id   = var.azure_subscription_id
  tenant_id         = var.azure_tenant_id
  client_id         = var.azure_client_id
  client_secret     = var.azure_client_secret
}

data "equinix_ecx_l2_sellerprofile" "azure" {
  name                     = "Azure ExpressRoute"
  organization_global_name = "Microsoft"
}

resource "azurerm_resource_group" "demo" {
  name     = var.azure_rg
  location = var.azure_location
}

resource "azurerm_express_route_circuit" "demo" {
  name = "F5GC-ExpressRoute"
  resource_group_name = azurerm_resource_group.demo.name
  location = azurerm_resource_group.demo.location
  service_provider_name = var. azure_service_provider_name
  peering_location = var.azure_peering_location
  bandwidth_in_mbps = var.equinix_ecx_l2_connection_speed
  sku {
    tier = "Premium"
    family = "UnlimitedData"
  }
  allow_classic_operations = false
}

resource "equinix_ecx_l2_connection" "router-to-azure" {
  name                = var.equinix_conn_name
  profile_uuid        = data.equinix_ecx_l2_sellerprofile.azure.id

  # Edge primary Router ID
  device_uuid         = var.equinix_network_edge_primary_vnf_uuid

  device_interface_id = var.equinix_network_edge_primary_vnf_interface_number
  speed               = var.equinix_ecx_l2_connection_speed
  speed_unit          = var.equinix_ecx_l2_connection_speed_unit
  notifications       = var.equinix_ecx_l2_connection_notifications
  seller_metro_code   = var.equinix_azure_metro_code
  authorization_key   = azurerm_express_route_circuit.demo.service_key
  named_tag           = "Private"
}

resource "azurerm_express_route_circuit_authorization" "demo" {
  name                       = "f5gc-ExpressRouteAuth"
  express_route_circuit_name = azurerm_express_route_circuit.demo.name
  resource_group_name        = azurerm_resource_group.demo.name
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [azurerm_express_route_circuit_authorization.demo]
  create_duration = "45s"
}

resource "azurerm_express_route_circuit_peering" "demo" {
  depends_on                    = [time_sleep.wait_30_seconds]
  peering_type                  = "AzurePrivatePeering"
  express_route_circuit_name    = azurerm_express_route_circuit.demo.name
  resource_group_name           = azurerm_resource_group.demo.name
  peer_asn                      = var.equinix_network_edge_primary_vnf_bgp_asn
  primary_peer_address_prefix   = var.azure_pri_ipv4
  secondary_peer_address_prefix = var.azure_sec_ipv4
  vlan_id                       = equinix_ecx_l2_connection.router-to-azure.zside_vlan_stag
  shared_key			        = var.bgp_password

  microsoft_peering_config {
    advertised_public_prefixes = var.azure_advertised_public_prefixes
 }
}

resource "time_sleep" "wait_x_seconds" {
  depends_on = [azurerm_express_route_circuit_peering.demo]
  create_duration = "360s"
}

resource "azurerm_virtual_network_gateway_connection" "f5gc-er-conn" {
  location                   = var.azure_location
  name                       = "F5GC-ER-CONN"
  resource_group_name        = azurerm_resource_group.demo.name
  type                       = "ExpressRoute"
  virtual_network_gateway_id = var.azure_er_gw_conn
  express_route_circuit_id   = azurerm_express_route_circuit.demo.id
  depends_on                 = [time_sleep.wait_x_seconds]
}









