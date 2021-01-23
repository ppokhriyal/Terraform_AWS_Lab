/*
-> Create one VPC
-> Create one Subnet
-> Create one Internet Gateway
-> Create one Route Table
-> Add IGW to Route
-> Associate Subnet to Route
-> Create one Security Group for SSH
-> Create Public SSH Key [ Refer readme for , how to create SSH Private and Public Key ]
-> Create one Ubuntu-20.04 EC2 instance
-> Install Docker in Ubuntu EC2 instance [ Refer dockerinstall.sh ]
*/

#Configure AWS Provider
provider "aws" {
  region = var.region
  access_key = var.accesskeyid
  secret_key = var.secretaccesskey
}

#Create VPC
 resource "aws_vpc" "custom_vpc" {
   cidr_block = var.vpcidr
   enable_dns_support = true
   enable_dns_hostnames = true

   tags = {
     "Name" = "Custom_VPC"
   }
 }

#Create Subnet
resource "aws_subnet" "custom_subnet1" {
    vpc_id = aws_vpc.custom_vpc.id
    cidr_block = var.subnetcidr
    availability_zone = element(var.azs,2)
    tags = {
      "Name" = "Custom_Subnet"
    }
}

#Create Internet Gateway
resource "aws_internet_gateway" "custom_igw" {
    vpc_id = aws_vpc.custom_vpc.id

    tags = {
      "Name" = "Custom_IGW"
    }
}

#Create Route Table
resource "aws_route_table" "custom_routetable" {
  vpc_id = aws_vpc.custom_vpc.id

  //add igw route
  route {
    cidr_block = "0.0.0.0/0"    
    gateway_id = aws_internet_gateway.custom_igw.id
  } 

  tags = {
    "Name" = "Custom_Route"
  }
}

#Associate Subnet to Route
resource "aws_route_table_association" "associate_subnet_toroute" {
    subnet_id = aws_subnet.custom_subnet1.id
    route_table_id = aws_route_table.custom_routetable.id
  
}

#Create Security Group [Allow SSH]
resource "aws_security_group" "custom_sg" {
  name = "allow_ssh"
  description = "allow ssh to ubuntu ec2 instance"
  vpc_id = aws_vpc.custom_vpc.id

  ingress{
      description = "SSH"
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress{
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress{
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress{
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    "Name" = "Custom_SG"
  }
}

#Public Key
resource "aws_key_pair" "dockerkey" {
  key_name = "docker-key"
  public_key = file(var.publickey)
}
#Create Ubuntu EC2 instance
resource "aws_instance" "Docker" {
  ami = "ami-0885b1f6bd170450c"
  instance_type = "t2.micro"
  availability_zone = element(var.azs,2)
  security_groups = [ aws_security_group.custom_sg.id ]
  subnet_id = aws_subnet.custom_subnet1.id
  associate_public_ip_address = true
  key_name = aws_key_pair.dockerkey.id

  provisioner "file" {
    source = "dockerinstall.sh"
    destination = "/tmp/dockerinstall.sh" 
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/dockerinstall.sh",
      "/tmp/dockerinstall.sh"
      ]
  }
  connection {
    type = "ssh"
    user = "ubuntu"
    host = aws_instance.Docker.public_ip
    private_key = file(var.privatekey) 
  }
  tags = {
    "Name" = "Docker_EC2"
  }
}
