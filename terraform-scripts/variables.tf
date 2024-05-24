variable "gitlab_instance_url" {
  type = string
}

variable "registration_token" {
  type = string
}

variable "rds_username" {
  type = string
  default = "victor"
}

variable "rds_password" {
  type = string
  default = "victor123"
}
