variable "user" {
  type = map(string)
}

variable "phys-domain" {
  type = string
}

variable "tenant" {
  type = string
}

variable "ap" {
  type = string
}

variable "vrf" {
  type = string
}

variable "bd" {
  type = map(string)
}

variable "filter" {
  type = map(string)
}

variable "contract" {
  type = map(string)
}

variable "l3out" {
  type = map(string)
}

variable "ext_subs" {
  type = set(string)
}

variable "nodes" {
  type = map(object({
    name   = string
    rtr_id = string
  }))
}

variable "vpc_members" {
  type = map(object({
    side = string
    addr = string
  }))
}

variable "static_path" {
  type = map(string)
}
