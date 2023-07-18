
provider "equinix" {
  client_id     = var.equinix_client_id
  client_secret = var.equinix_client_secret
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
#  aws_account_id = var.aws_account_id
}

data "equinix_ecx_l2_sellerprofile" "aws" {
  name                     = "AWS Direct Connect"
  organization_global_name = "AWS"
}

resource "equinix_ecx_l2_connection" "router-to-aws" {
  name                = var.equinix_conn_name
  profile_uuid        = data.equinix_ecx_l2_sellerprofile.aws.id

  # Edge primary Router ID
  device_uuid         = var.equinix_network_edge_primary_vnf_uuid

  device_interface_id = var.equinix_network_edge_primary_vnf_interface_number
  speed               = var.equinix_ecx_l2_connection_speed
  speed_unit          = var.equinix_ecx_l2_connection_speed_unit
  notifications       = var.equinix_ecx_l2_connection_notifications
  seller_metro_code   = var.equinix_aws_metro_code
  seller_region       = var.aws_region
  authorization_key   = var.aws_account_id
  #named_tag         = var.equinix_ecx_l2_connection_notifications_named_tag
}

locals  {
   aws_connection_id = one([
       for action_data in one(equinix_ecx_l2_connection.router-to-aws.actions).required_data: action_data["value"]
       if action_data["key"] == "awsConnectionId"
   ])
}

resource "aws_dx_connection_confirmation" "confirmation" {
  connection_id = local.aws_connection_id
  #connection_id = equinix_ecx_l2_connection.router-to-aws.name
}

resource "aws_dx_private_virtual_interface" "example" {
  connection_id    = aws_dx_connection_confirmation.confirmation.id
  name             = var.aws_private_vif_name
  vlan             = equinix_ecx_l2_connection.router-to-aws.zside_vlan_stag
  address_family   = "ipv4"
  bgp_asn          = var.equinix_network_edge_primary_vnf_bgp_asn
  amazon_address   = var.aws_vif_ipv4
  customer_address = var.equinix_vnf_ipv4
  bgp_auth_key     = var.bgp_password
  vpn_gateway_id   = var.aws_vgw_name
}



