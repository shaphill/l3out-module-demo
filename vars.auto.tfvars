user = {
  username = "ADMIN"
  password = "PASSWORD"
  url      = "HOSTNAME"
}

phys-domain = "sp-phys"
tenant      = "sp-l3out-demo"
ap          = "lab"
vrf         = "v1"
bd = {
  name = "fabric-bd"
  ip   = "10.0.0.1/24"
}

filter = {
  name  = "ospf-host-filter"
  entry = "ospf-host-entry"
}

contract = {
  name    = "ospf-host-contract"
  subject = "ospf-host-filter"
}

static_path = {
  path  = "topology/pod-1/protpaths-101-102/pathep-[sp-vpc]"
  encap = "vlan-106"
}
