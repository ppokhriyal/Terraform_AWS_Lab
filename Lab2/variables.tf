//Region
variable "region" {
  default = "us-east-1"
}

//AccessKeyId
variable "accesskeyid" {}

//Sceretaccesskey
variable "secretaccesskey" {}

//VPC CIDR
variable "vpcidr" {
  default = "10.0.0.0/16"
}

//Public Subnet CIDR
variable "publicsubnetcidr" {
  default = "10.0.0.0/24"
}

//Private Subnet CIDR
variable "privatesubnetcidr" {
  default = "10.0.1.0/24"
}

//Avialability Zones
data "aws_availability_zones" "azs" {}

//Private Key
variable "privatekey" {
  default = "sshkey"
}

//Public Key
variable "publickey" {
  default = "sshkey.pub"
}
