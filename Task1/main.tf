provider "aws" {
  region = "us-east-1"
}


locals {
  name_tag = "Kashish_Omar"
  vpc_cidr = "10.0.0.0/16"
}


resource "aws_vpc" "assessment_vpc" {
  cidr_block           = local.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name        = "${local.name_tag}_VPC"
    Environment = "Assessment_Task_1"
  }
}


resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.assessment_vpc.id

  tags = {
    Name = "${local.name_tag}_IGW"
  }
}


resource "aws_subnet" "public_az1" {
  vpc_id                  = aws_vpc.assessment_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name_tag}_Public_Subnet_AZ1"
  }
}

resource "aws_subnet" "public_az2" {
  vpc_id                  = aws_vpc.assessment_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name_tag}_Public_Subnet_AZ2"
  }
}


resource "aws_subnet" "private_az1" {
  vpc_id            = aws_vpc.assessment_vpc.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "${local.name_tag}_Private_Subnet_AZ1"
  }
}

resource "aws_subnet" "private_az2" {
  vpc_id            = aws_vpc.assessment_vpc.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "${local.name_tag}_Private_Subnet_AZ2"
  }
}


resource "aws_eip" "nat_eip" {
  domain = "vpc"
  
  tags = {
    Name = "${local.name_tag}_NAT_EIP"
  }
}

resource "aws_nat_gateway" "main_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_az1.id

  tags = {
    Name = "${local.name_tag}_NAT_Gateway"
  }
  
  depends_on = [aws_internet_gateway.main_igw]
}


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.assessment_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "${local.name_tag}_Public_RT"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.assessment_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main_nat.id
  }

  tags = {
    Name = "${local.name_tag}_Private_RT"
  }
}


resource "aws_route_table_association" "public_assoc_1" {
  subnet_id      = aws_subnet.public_az1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.public_az2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_assoc_1" {
  subnet_id      = aws_subnet.private_az1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_assoc_2" {
  subnet_id      = aws_subnet.private_az2.id
  route_table_id = aws_route_table.private_rt.id
}