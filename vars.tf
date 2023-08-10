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

variable "static_path" {
  type = map(string)
}
