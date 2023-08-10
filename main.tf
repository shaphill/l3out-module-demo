terraform {
  required_providers {
    aci = {
      source = "CiscoDevNet/aci"
    }
  }
}

provider "aci" {
  username = var.user.username
  password = var.user.password
  url      = var.user.url
  insecure = true
}

data "aci_physical_domain" "phys" {
  name = var.phys-domain
}

data "aci_l3_domain_profile" "l3-domain" {
  name = var.l3out.domain
}

resource "aci_tenant" "tenant" {
  name = var.tenant
}

resource "aci_application_profile" "ap" {
  tenant_dn = aci_tenant.tenant.id
  name      = "lab"
}

resource "aci_vrf" "vrf" {
  tenant_dn = aci_tenant.tenant.id
  name      = var.vrf
}

resource "aci_bridge_domain" "bd" {
  tenant_dn                = aci_tenant.tenant.id
  name                     = var.bd.name
  relation_fv_rs_ctx       = aci_vrf.vrf.id
  relation_fv_rs_bd_to_out = [module.l3out_ospf.l3out_dn]
}

resource "aci_subnet" "subnet" {
  parent_dn = aci_bridge_domain.bd.id
  ip        = var.bd.ip
  scope     = ["public"]
}

resource "aci_application_epg" "epg" {
  application_profile_dn = aci_application_profile.ap.id
  name                   = "host"
  relation_fv_rs_bd      = aci_bridge_domain.bd.id
}

resource "aci_epg_to_domain" "epgdom" {
  application_epg_dn = aci_application_epg.epg.id
  tdn                = data.aci_physical_domain.phys.id
}

resource "aci_filter" "filter" {
  tenant_dn = aci_tenant.tenant.id
  name      = var.filter.name
}

resource "aci_filter_entry" "filter_entry" {
  filter_dn = aci_filter.filter.id
  name      = var.filter.entry
}

resource "aci_contract" "contract" {
  tenant_dn = aci_tenant.tenant.id
  name      = var.contract.name
}

resource "aci_contract_subject" "contract_subject" {
  contract_dn                  = aci_contract.contract.id
  name                         = var.contract.subject
  relation_vz_rs_subj_filt_att = [aci_filter.filter.id]
}

resource "aci_epg_to_contract" "epg_contract" {
  application_epg_dn = aci_application_epg.epg.id
  contract_dn        = aci_contract.contract.id
  contract_type      = "provider"
}

resource "aci_epg_to_static_path" "epg_path" {
  application_epg_dn = aci_application_epg.epg.id
  tdn                = var.static_path.path
  encap              = var.static_path.encap
}

module "l3out_ospf" {
  source       = "./modules/l3out"
  tenant_dn    = aci_tenant.tenant.id
  name         = "l3-ospf"
  description  = "Created by l3out module"
  vrf_dn       = aci_vrf.vrf.id
  l3_domain_dn = data.aci_l3_domain_profile.l3-domain.id

  ospf = {
    area_id   = "0"
    area_type = "regular"
  }

  vpcs = [
    {
      ospf_interface_profile = {
      }
      pod_id = 1
      nodes = [
        {
          node_id            = "103"
          router_id          = "103.103.103.103"
          router_id_loopback = "yes"
        },
        {
          node_id            = "104"
          router_id          = "104.104.104.104"
          router_id_loopback = "yes"
        }
      ]
      interfaces = [
        {
          channel = "sp-vpc"
          vlan    = "107"
          mtu     = "1500"
          side_a = {
            ip = "10.0.1.2/24"
          }
          side_b = {
            ip = "10.0.1.3/24"
          }
        }
      ]
    }
  ]

  external_epgs = [
    {
      name = "l3-ospf-epg"
      consumed_contracts = [
        aci_contract.contract.id
      ]
      subnets = [
        {
          ip    = "0.0.0.0/0"
          scope = ["import-security"]
        },
        {
          ip    = "10.0.1.0/24"
          scope = ["import-security"]
        }
      ]
    }
  ]
}
