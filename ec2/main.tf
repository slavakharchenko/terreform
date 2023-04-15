data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["Terraform_VPC"]
  }
}

data "aws_subnet" "public_subnet" {
  filter {
    name   = "tag:Name"
    values = ["Terraform_public_subnet"]
  }
}

data "aws_subnet" "private_subnet" {
  filter {
    name   = "tag:Name"
    values = ["Terraform_private_subnet"]
  }
}

resource "aws_security_group" "security_group_for_public_ec2" {
  vpc_id = data.aws_vpc.vpc.id
  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name    = "Terraform_security_group_for_public_ec2"
    project = "training_terraform"
  }
}

resource "aws_security_group" "security_group_for_private_ec2" {
  vpc_id = data.aws_vpc.vpc.id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [data.aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name    = "Terraform_security_group_for_private_ec2"
    project = "training_terraform"
  }
}

resource "aws_instance" "ec2_for_public_subnet" {
  ami             = "ami-08722fffad032e569"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.security_group_for_public_ec2.id]

  key_name  = "ec2"
  user_data = file("webserver.sh")

  subnet_id = data.aws_subnet.public_subnet.id

  tags = {
    Name    = "Terraform_ec2_for_public_subnet"
    project = "training_terraform"
  }
}

resource "aws_instance" "ec2_for_private_subnet" {
  ami             = "ami-08722fffad032e569"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.security_group_for_private_ec2.id]

  key_name  = "ec2"
  subnet_id = data.aws_subnet.private_subnet.id

  tags = {
    Name    = "Terraform_ec2_for_private_subnet"
    project = "training_terraform"
  }
}