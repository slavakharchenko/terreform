provider "aws" {
  region  = "eu-central-1"
}

// Virtual Private Cloud
resource "aws_vpc" "terraform_vpc" {
  cidr_block       = "10.0.0.0/24"
  instance_tenancy = "default"

  tags = {
    Name = "Terraform_VPC"
    project = "training_terraform"
  }
}

// Public subnet with internet gateway in route table
resource "aws_subnet" "terraform_public_subnet" {
  vpc_id     = aws_vpc.terraform_vpc.id
  cidr_block = "10.0.0.16/28"
  map_public_ip_on_launch = true

  tags = {
    Name = "Terraform_public_subnet"
    project = "training_terraform"
  }
}

resource "aws_internet_gateway" "terraform_internet_gateway" {
  vpc_id = aws_vpc.terraform_vpc.id

  tags = {
    Name = "Terraform_internet_gateway"
    project = "training_terraform"
  }
}

resource "aws_route_table" "terraform_public_route_table" {
  vpc_id = aws_vpc.terraform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform_internet_gateway.id
  }

  tags = {
    Name = "Terraform_public_route_table"
    project = "training_terraform"
  }
}

resource "aws_route_table_association" "aws_public_route_table_association" {
  subnet_id      = aws_subnet.terraform_public_subnet.id
  route_table_id = aws_route_table.terraform_public_route_table.id
}

// Public subnet with NAT gateway in route table
resource "aws_subnet" "terraform_private_subnet" {
  vpc_id     = aws_vpc.terraform_vpc.id
  cidr_block = "10.0.0.0/28"

  tags = {
    Name = "Terraform_private_subnet"
    project = "training_terraform"
  }
}

resource "aws_eip" "eip_nat_gateway" {
  vpc = true
}

resource "aws_nat_gateway" "terraform_NAT_gateway" {
  subnet_id     = aws_subnet.terraform_public_subnet.id
  allocation_id = aws_eip.eip_nat_gateway.id

  tags = {
    Name = "Terraform_NAT_gateway"
    project = "training_terraform"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.terraform_internet_gateway]
}

resource "aws_route_table" "terraform_private_route_table" {
  vpc_id = aws_vpc.terraform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.terraform_NAT_gateway.id
  }

  tags = {
    Name = "Terraform_private_route_table"
    project = "training_terraform"
  }
}

resource "aws_route_table_association" "aws_private_route_table_association" {
  subnet_id      = aws_subnet.terraform_private_subnet.id
  route_table_id = aws_route_table.terraform_private_route_table.id
}


