variable "vpc-id" {
  type   = string
}

variable "map-public-ip-on-launch" {
  type    = bool
  default = false
}

variable "cidr-block" {
  type   = string
}

variable "name" {
  type   = string
  
}