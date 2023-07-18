
# define provider version and Metal Token
terraform {
  required_providers {
    equinix = {
      source = "equinix/equinix"
      #version = "1.8.0"
    }
    metal = {
      source = "equinix/metal"
    }
  }
}

provider "equinix" {
  client_id     = var.equinix_client_id
  client_secret = var.equinix_client_secret
  auth_token    = var.auth_token
}

variable "equinix_client_id" {}
variable "equinix_client_secret" {}

variable "auth_token" {}

variable "project_id" {}
variable "node_count" {}
variable "plan" {}
variable "metro" {}
variable "operating_system" {}
variable "metal_vlan" {}
variable "metal_vlan_metro" {}
variable "ssh_key" {}
variable "eqx_metal_connection_name"                {}
variable "eqx_metal_connection_redundancy"          {}
variable "eqx_metal_connection_type"                {}
variable "eqx_metal_connection_mode"                {}
variable "eqx_metal_connection_speed"               {}
variable "eqx_metal_connection_service_token_type"  {}
variable "eqx_metal_primary_connection_vlan"        {}

variable "eqx_ecx_l2_connection_speed"                   {}
variable "eqx_ecx_l2_connection_speed_unit"              {}
variable "eqx_fabric_metro_code"                         {}
variable "eqx_network_edge_primary_vnf_uuid"             {}
variable "eqx_network_edge_primary_vnf_interface_number" {}
variable "eqx_ecx_l2_connection_notifications"           {}
variable "eqx_ecx_l2_connection_name"                    {}
variable "eqx_metal_organization_id"                     {}
variable "vlan_count"                                    {}

resource "equinix_metal_vlan" "metro_vlan" {
  count       = var.vlan_count
  description = "Metal's metro VLAN"
  metro       = var.metro
  vxlan       = var.metal_vlan
  project_id  = var.project_id
}

resource "equinix_metal_connection" "F5GC_METAL_CONNECTION" {
    depends_on      = [equinix_metal_vlan.metro_vlan]
    name            = var.eqx_metal_connection_name
    organization_id = var.eqx_metal_organization_id
    project_id      = var.project_id
    # Small case letters
    metro           = var.metro
    # primary / redundant
    redundancy      = var.eqx_metal_connection_redundancy
    # dedicated or shared
    type            = var.eqx_metal_connection_type
    mode            = var.eqx_metal_connection_mode
    # Speed
    speed           = var.eqx_metal_connection_speed
    # Service token type
    service_token_type = var.eqx_metal_connection_service_token_type



    # VLANS
    # One entry for primary, 2 elemens for primary and
    # secondary
    vlans              = [ var.eqx_metal_primary_connection_vlan ]
}

resource "equinix_ecx_l2_connection" "F5GC_METAL_2_NE_CONNECTION" {
  # expected length of secondary_connection.0.name to be in the range (1 - 24)
  name                    = var.eqx_ecx_l2_connection_name
  device_uuid             = var.eqx_network_edge_primary_vnf_uuid
  device_interface_id     = var.eqx_network_edge_primary_vnf_interface_number
  speed                   = var.eqx_ecx_l2_connection_speed
  speed_unit              = var.eqx_ecx_l2_connection_speed_unit
  notifications           = var.eqx_ecx_l2_connection_notifications

  # This metro must be the same you specified in the
  # Metal connection request
  seller_metro_code       = var.eqx_fabric_metro_code

  # Metal connection service token from
  zside_service_token     = equinix_metal_connection.F5GC_METAL_CONNECTION.service_tokens.0.id
}

# create metal nodes
resource "equinix_metal_device" "metal_nodes" {
  depends_on       = [equinix_metal_connection.F5GC_METAL_CONNECTION, equinix_ecx_l2_connection.F5GC_METAL_2_NE_CONNECTION]
  #count            = var.node_count
  hostname         = format("forte-edge-cloud-%d",  1)
  plan             = var.plan
  metro            = var.metro
  operating_system = var.operating_system
  billing_cycle    = "hourly"
  project_id       = var.project_id
  #network_type     = "hybrid"
  user_data        = data.cloudinit_config.config.rendered
  #depends_on       = [var.metal_vlan, var.metal_vlan_metro]
  #depends_on       = [vterraform planar.metal_vlan, var.ssh_key]
  reinstall {
    enabled = true
  }
}

data "cloudinit_config" "config" {
  #count = var.node_count
  gzip = false
  # not supported on Equinix Metal
  base64_encode = false
  # not supported on Equinix Metal

  part {
    content_type = "text/x-shellscript"
    content = file("${path.module}/pre-cloud-config.sh")
  }


  # Main cloud-config configuration file.
  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-config.cfg", {
      VLAN_ID_0 = var.metal_vlan
      #VLAN_ID_1  = var.metal_vlan[1].vxlan
      LAST_DIGIT = 25
    })
  }
}

/*## Example for executing scripts on metal nodes
resource "null_resource" "ssh-after-deploy" {
  count      = var.node_count
  depends_on = [equinix_metal_port.port]
  connection {
    host        = equinix_metal_device.metal_nodes[count.index].access_public_ipv4
    type        = "ssh"
    user        = "root"
    private_key = var.ssh_key
  }
}*/

## put metal nodes in unbonded mode and attach metro vlan to the nodes
resource "equinix_metal_port" "port" {
  count = var.node_count
  #port_id = "eth1"
  port_id  = [for p in equinix_metal_device.metal_nodes.ports : p.id if p.name == "bond0"][0]
  #layer2   = true
  bonded   = true
  #network_type = "hybrid"
  vxlan_ids = [var.metal_vlan]
  depends_on = [equinix_metal_device.metal_nodes]
}

resource "equinix_metal_device_network_type" "metal_nodes" {
  device_id = equinix_metal_device.metal_nodes.id
  type      = "hybrid"
}



