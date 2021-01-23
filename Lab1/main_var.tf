//AccessKeyID,SecretAccessKey
variable "accesskeyid" {}
variable "secretaccesskey" {}

//Region
variable "region" {
  default = "us-east-1"
}

//VPC CIDR
variable "vpcidr" {
  default = "10.0.0.0/16"
}
//Subnet CIDR
variable "subnetcidr" {
  default = "10.0.0.0/24"
}
//Availability Zones
variable "azs" {
  type = list
  default = ["us-east-1a","us-east-1b","us-east-1c","us-east-1d","us-east-1e","us-east-1f"]
}

//Public Key Path
variable "publickey" {
  default = "dockerkey.pub"
}
//Private Key Path
variable "privatekey" {
  default = "dockerkey"
}
