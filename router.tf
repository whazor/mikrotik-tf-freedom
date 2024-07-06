terraform {
  required_providers {
    routeros = {
      source = "terraform-routeros/routeros"
    }
  }
}

provider "routeros" {
  hosturl  = "http://192.168.88.1"
  username = "admin"
  password = "YOUR_PASSWORD_HERE"
  insecure       = true 
}

# :put [/interface/bridge get [print show-ids]]
# tofu import routeros_interface_bridge.ether1 "*1"
resource "routeros_interface_bridge" "bridge" {
  name = "bridge"
#   admin_mac = "AA:BB:CC:DD:EE:FF"
  auto_mac = false
}

# :put [/interface/ethernet get [print show-ids]]
# tofu import routeros_interface_ethernet.ether1 "*1"
resource "routeros_interface_ethernet" "ether1" {
  name = "ether1"
  factory_name = "ether1"
  loop_protect = "off"
  mtu = 1508
}

# :put [/interface/vlan get [print show-ids]]
# tofu import routeros_interface_vlan.bridge-WAN "*9"
resource "routeros_interface_vlan" "bridge-WAN" {
  interface = "ether1"
  mtu = 1508
  name = "bridge-WAN"
  vlan_id = 6
}

# /interface pppoe-client
# :put [/interface/pppoe-client get [print show-ids]]
# tofu import routeros_interface_pppoe_client.pppoe-client "*A"
resource "routeros_interface_pppoe_client" "pppoe-client" {
  add_default_route = true
  allow = ["pap"]
  disabled = false
  interface = "bridge-WAN"
  max_mru = 1500
  max_mtu = 1500
  name = "pppoe-client"
  service_name = "Freedom Internet"
  use_peer_dns = true
  user = "fake@freedom.nl"
  password = "1234"
}

# :put [/ip/dhcp-client get [print show-ids]]
# tofu import routeros_ip_dhcp_client.bridge-WAN "*2"
resource "routeros_ip_dhcp_client" "bridge-WAN" {
  interface = "bridge-WAN"
  comment = "defconf"
  
}

# :put [/ip/firewall/nat get [print show-ids]] -> *1
# tofu import routeros_ip_firewall_nat.defconf "*1"
resource "routeros_ip_firewall_nat" "defconf" {
  action = "masquerade"
  chain = "srcnat"
  comment = "defconf: masquerade"
  ipsec_policy = "out,none"
  out_interface = "pppoe-client"
}