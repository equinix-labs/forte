# define provider version and Metal Token
terraform {
  required_providers {
    equinix = {
      source = "equinix/equinix"
      version = "= 1.13.0"
    }
  }
}

provider "equinix" {
  auth_token = var.auth_token
}


# allocate a metal's metro vlans for the project

/*resource "equinix_metal_vlan" "metro_vlan" {
  count       = var.vlan_count
  description = "Metal's metro VLAN"
  metro       = var.metro
  vxlan       = var.metal_vlan
  project_id  = var.project_id
}*/

# creat a temporary SSH key pairs for the project
module "ssh" {
  source     = "./modules/ssh/"
  project_id = var.project_id
}

# deploy Metal server(s)

module "metal_nodes" {
  source           = "./modules/metalnodes/"
  project_id       = var.project_id
  node_count       = var.server_count
  plan             = var.plan
  metro            = var.metro
  operating_system = var.operating_system
  metal_vlan       = var.metal_vlan
  metal_vlan_metro = var.metal_vlan_metro
  eqx_ecx_l2_connection_name = var.eqx_ecx_l2_connection_name
  # metal_vlan       = [for v in equinix_metal_vlan.metro_vlan[*] : { vxlan = v.vxlan, id = v.id }]
  ssh_key          = module.ssh.ssh_private_key_contents
  # depends_on       = [equinix_metal_vlan.metro_vlan, module.ssh]
  eqx_ecx_l2_connection_notifications = var.eqx_ecx_l2_connection_notifications
  eqx_metal_connection_name = var.eqx_metal_connection_name
  eqx_ecx_l2_connection_speed_unit = var.eqx_ecx_l2_connection_speed_unit
  eqx_ecx_l2_connection_speed = var.eqx_ecx_l2_connection_speed
  eqx_network_edge_primary_vnf_interface_number = var.eqx_network_edge_primary_vnf_interface_number
  eqx_metal_primary_connection_vlan = var.eqx_metal_primary_connection_vlan
  eqx_fabric_metro_code = var.eqx_fabric_metro_code
  eqx_network_edge_primary_vnf_uuid = var.eqx_network_edge_primary_vnf_uuid
  eqx_metal_organization_id = var.eqx_metal_organization_id
  vlan_count = var.vlan_count
  eqx_metal_connection_mode = var.eqx_metal_connection_mode
  eqx_metal_connection_redundancy = var.eqx_metal_connection_redundancy
  eqx_metal_connection_type = var.eqx_metal_connection_type
  eqx_metal_connection_speed = var.eqx_metal_connection_speed
  eqx_metal_connection_service_token_type = var.eqx_metal_connection_service_token_type
  equinix_client_id= var.equinix_client_id
  equinix_client_secret = var.equinix_client_secret
  auth_token = var.auth_token
}
