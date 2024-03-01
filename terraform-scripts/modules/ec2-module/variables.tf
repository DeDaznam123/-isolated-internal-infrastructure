variable "ingress-rules"{
    type = list(object({
        from_port   = number
        to_port     = number
        protocol    = string
        cidr_blocks = list(string)
        description = string
    }))
}
variable "user_data" {
    type = string
    default = ""
  
}
variable "vpc-id" {
  type = string
}
variable "ami" {
    type    = string
    default = "ami-03614aa887519d781"
}

variable "instance-type" {
    type    = string
    default = "t3.micro"
}

variable "key-name" {
    type    = string
    default = "victor_handzhiev"
}

variable "subnet-id" {
    type    = string
}

variable "name" {
    type   = string
}

variable "volume-size" {
    type    = number
}

variable "volume-type" {
    type    = string
    default = "gp2"
}