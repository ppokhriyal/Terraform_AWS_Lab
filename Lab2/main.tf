/*
-> Create VPC
-> Create two subnets Public and Private
-> Create Internet Gateway
-> Create two Route tables Public and Private
-> Associate Public Subnet to Public Route
-> Associate Private Subnet to Private Route
-> Create Elastic IP for NAT
-> Create SSH Key
-> Create two EC2 instances one in Public subnet and one in Private Subnet
-> Create NAT and attache it to Public Subnet
-> Add NAT in Private Route table
*/

#Configure AWS Provide
provider "aws" {
  region = var.region
  access_key = var.accesskeyid
  secret_key = var.secretaccesskey
}

#Create VPC
resource "aws_vpc" "customvpc" {
  cidr_block =  var.vpcidr
  tags = {
    "Name" = "customvpc"
  }
}

#Create Public Subnet
resource "aws_subnet" "publicsubnet" {
  vpc_id = aws_vpc.customvpc.id
  cidr_block = var.publicsubnetcidr
  availability_zone = data.aws_availability_zones.azs.names[0]

  tags = {
    "Name" = "publicsubnet"
  }
}

#Create Private Subnet
resource "aws_subnet" "privatesubnet" {
  vpc_id = aws_vpc.customvpc.id
  cidr_block = var.privatesubnetcidr
  availability_zone =  data.aws_availability_zones.azs.names[1]
  tags = {
    "Name" = "privatesubnet"
  }
}

#Create Internet Gateway
resource "aws_internet_gateway" "customigw" {
    vpc_id = aws_vpc.customvpc.id
    tags = {
      "Name" = "customigw"
    }
}

#Create Public Route Table
resource "aws_route_table" "publicroute" {
  vpc_id = aws_vpc.customvpc.id
  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.customigw.id
  }
  tags ={
      "Name" = "publicroute"
  } 
}

#Associate Public Subnet to Public Route
resource "aws_route_table_association" "publicsubass" {
  subnet_id = aws_subnet.publicsubnet.id
  route_table_id = aws_route_table.publicroute.id
}

#Create Private Route
resource "aws_route_table" "privateroute" {
  vpc_id = aws_vpc.customvpc.id
  route{
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.awsnat.id
  }
  tags = {
    "Name" = "privateroute"
  }
}

#Associate Private Subnet to Private Route
resource "aws_route_table_association" "privatesubass" {
  subnet_id = aws_subnet.privatesubnet.id
  route_table_id = aws_route_table.privateroute.id
}

#Elastic IP
resource "aws_eip" "awseip" {
  vpc = true
}


#Public Security Group
resource "aws_security_group" "sshsg" {
  name = "allowssh"
  description = "allow ssh to other instances"
  vpc_id = aws_vpc.customvpc.id

  ingress {
    description = "allow ssh"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress{
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "sshsg"
  }
}

#Create SSH Keypair
resource "aws_key_pair" "sshkey" {
  key_name = "sshkey"
  public_key = file(var.publickey)
}

#Create EC2 Instance in Public Subnet
resource "aws_instance" "publicec2" {
  ami = "ami-0885b1f6bd170450c"
  instance_type = "t2.micro"
  availability_zone = data.aws_availability_zones.azs.names[0]
  security_groups = [ aws_security_group.sshsg.id ]
  subnet_id = aws_subnet.publicsubnet.id
  associate_public_ip_address = true
  key_name = aws_key_pair.sshkey.id
  tags = {
    "Name" = "publicec2"
  }
}

#Create EC2 Instance in Private Subnet
resource "aws_instance" "privateec2" {
  ami = "ami-0885b1f6bd170450c"
  instance_type = "t2.micro"
  availability_zone = data.aws_availability_zones.azs.names[1]
  security_groups = [ aws_security_group.sshsg.id ]
  subnet_id = aws_subnet.privatesubnet.id
  associate_public_ip_address = false
  key_name = aws_key_pair.sshkey.id
  tags = {
    "Name" = "privateec2"
  }
}
#Create NAT
resource "aws_nat_gateway" "awsnat" {
    allocation_id = aws_eip.awseip.id
    subnet_id = aws_subnet.publicsubnet.id

    tags = {
      "Name" = "nat"
    }
}
