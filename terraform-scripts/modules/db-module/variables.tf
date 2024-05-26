variable "security_groups"{
    type = list(string)
}

variable "password" {
    type = string
}

variable "username" {
    type = string
}

variable "vpc-id" {
  type = string
}

variable "subnet-id" {
    type = list(string)
}
