############################################
# VPC
############################################
resource "aws_vpc" "carservice_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "carservice-vpc"
  }
}

############################################
# Subnet
############################################
resource "aws_subnet" "carservice_subnet" {
  vpc_id                  = aws_vpc.carservice_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags = {
    Name = "carservice-subnet"
  }
}

############################################
# Internet Gateway
############################################
resource "aws_internet_gateway" "carservice_igw" {
  vpc_id = aws_vpc.carservice_vpc.id

  tags = {
    Name = "carservice-igw"
  }
}

############################################
# Route Table
############################################
resource "aws_route_table" "carservice_rt" {
  vpc_id = aws_vpc.carservice_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.carservice_igw.id
  }

  tags = {
    Name = "carservice-rt"
  }
}

############################################
# Route Table Association
############################################
resource "aws_route_table_association" "carservice_rta" {
  subnet_id      = aws_subnet.carservice_subnet.id
  route_table_id = aws_route_table.carservice_rt.id
}

############################################
# Security Group
############################################
resource "aws_security_group" "carservice_sg" {
  name        = "carservice-sg"
  description = "Security group for CarService EC2"
  vpc_id      = aws_vpc.carservice_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "HTTP NodePort"
    from_port   = 30080
    to_port     = 30080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "carservice-sg"
  }
}

############################################
# AMI
############################################
data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

############################################
# EC2 Instance
############################################
resource "aws_instance" "carservice_ec2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.carservice_subnet.id
  vpc_security_group_ids = [aws_security_group.carservice_sg.id]

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
  }

  user_data = file("${path.module}/user_data.sh")

  tags = {
    Name = "carservice-k8s-helm"
  }
}
