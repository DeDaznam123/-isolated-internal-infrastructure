variable "vpc-id" {
    type   = string
}

variable "cidr-block" {
    type   = string
}

variable "name" {
    type   = string
}

variable "IG-id" {
    type   = string  
    default = null
}

variable "subnet-id" {
    type = string
}

variable "NG-id" {
    type = string
    default = null
}

variable "use-internet-gateway" {
    type = bool
}
