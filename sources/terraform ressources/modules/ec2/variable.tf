variable "maintainer" {
  type    = string
  default = "adda"
}

variable "instance_type" {
  type    = string
  default = "t2.nano"
}

variable "ssh_key" {
  type    = string
  default = "devops"
}

variable "sg_name" {
  type    = string
  default = "NULL"
}

variable "server_name" {
  type    = string
  default = "NULL"
}

variable "public_ip" {
  type    = string
  default = "NULL"
}

variable "projet_name" {
  type    = string
  default = "ic-webapp"
}

variable "AZ" {
  type    = string
  default = "eu-west-3a"
}

variable "user" {
  type    = string
  default = "ec2-user"
}
