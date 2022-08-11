## VERSION
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

## VPC
provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "user-vpc"
  }
}

## SUBENT
resource "aws_subnet" "publicSubnet1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "ap-northeast-2a"
  tags = {
    "Name" = "user-public-subnet-01"
  }
}

resource "aws_subnet" "publicSubnet2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-2b"
  tags = {
    "Name" = "user-public-subnet-02"
  }
}

# private rds subnet
resource "aws_subnet" "privateSubnet1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-northeast-2a"
  tags = {
    "Name" = "user-private-subnet-01"
  }
}

resource "aws_subnet" "privateSubnet2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "ap-northeast-2b"
  tags = {
    "Name" = "user-private-subnet-02"
  }
} 