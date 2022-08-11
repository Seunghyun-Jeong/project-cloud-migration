resource "aws_vpc" "PM-VPC" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  instance_tenancy = "default"

  tags = {
    Name = "VPC-PM"
  }
}
resource "aws_default_route_table" "PM-VPC" {
  default_route_table_id = "${aws_vpc.PM-VPC.default_route_table_id}"

  tags = {
    Name = "PM-default"
  }
}

data "aws_availability_zones" "available" { 
    filter { 
        name = "zone-name" 
        values =["ap-northeast-2a","ap-northeast-2c"] 
    } 
}

resource "aws_subnet" "PM-VPC_public_subnet1" {
  vpc_id = "${aws_vpc.PM-VPC.id}"
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  tags = {
    Name = "PM-Public-az-1"
  }
}

resource "aws_subnet" "PM-VPC_public_subnet2" {
  vpc_id = "${aws_vpc.PM-VPC.id}"
  cidr_block = "10.0.1.0/24"  
  map_public_ip_on_launch = true
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  tags = {
    Name = "PM-Public-az-2"
  }
}

resource "aws_subnet" "PM-VPC_private_subnet1" {
  vpc_id = "${aws_vpc.PM-VPC.id}"
  cidr_block = "10.0.16.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  tags = {
    Name = "PM-Private-az-1"
  }
}

resource "aws_subnet" "PM-VPC_private_subnet2" {
  vpc_id = "${aws_vpc.PM-VPC.id}"
  cidr_block = "10.0.128.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  tags = {
    Name = "PM-Private-az-2"
  }
}

