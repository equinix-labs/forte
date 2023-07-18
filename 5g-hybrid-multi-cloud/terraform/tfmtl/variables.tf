variable "equinix_client_id" {}
variable "equinix_client_secret" {}
variable "equinix_port_name" {}
variable "aws_account_id" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}
variable "aws_metro_code" {}


variable "eqx_metal_connection_name"                {}
variable "eqx_metal_connection_redundancy"          { default = "primary" }
variable "eqx_metal_connection_type"                { default = "shared" }
variable "eqx_metal_connection_mode"                { default = "standard" }
variable "eqx_metal_connection_speed"               { default = "200Mbps" }
variable "eqx_metal_connection_service_token_type"  { default = "a_side"}
variable "eqx_metal_primary_connection_vlan"        {}
variable "eqx_metal_organization_id"                {}

variable "eqx_ecx_l2_connection_speed"                   {}
variable "eqx_ecx_l2_connection_speed_unit"              {}
variable "eqx_fabric_metro_code"                         {}
variable "eqx_network_edge_primary_vnf_uuid"             {}
variable "eqx_network_edge_primary_vnf_interface_number" {}
variable "eqx_ecx_l2_connection_notifications"           {}
variable "eqx_ecx_l2_connection_name"                    {}




variable "auth_token" {
  type        = string
  description = "Your Equinix Metal API key (https://console.equinix.com/users/-/api-keys)"
  sensitive   = true
}

variable "project_id" {
  type        = string
  description = "Your Equinix Metal project ID, where you want to deploy your nodes to"
}

variable "plan" {
  type        = string
  description = "Metal server type you plan to deploy"
  default     = "c3.small.x86"
}

variable "operating_system" {
  type        = string
  description = "OS you want to deploy"
  default     = "ubuntu_20_04"
}

variable "metro" {
  type        = string
  description = "Metal's Metro location you want to deploy your servers to"
  default     = null
}

variable "server_count" {
  type        = number
  description = "numbers of backend nodes you want to deploy"
  default     = 1
}

variable "vlan_count" {
  type        = number
  description = "Metal's Metro VLAN"
  default     = 1
}

variable "nni_vlan" {
  type        = number
  description = "Your fabric virtual circuit's NNI VLAN connecting to your VRF"
  default     = null
}

variable "metal_vlan" {
  type        = number
  default     = null
}

variable "metal_vlan_metro" {
  type        = number
  default     = null
}
