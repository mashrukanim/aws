# This is the main file responsible for building the infrastructure of EC2 instance

# The main terraform block that specifies that aws provideris goign to be used
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Provider block
# Configuring the default region that AWS Provider is in
provider "aws" {
  region = "us-east-1"
}

# Data block
# This block is the image that we want the EC2 instances to use
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"] # So requesting that data from aws
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Aws key pair
# It will pair up my aws with this machine so the machine knows where it is sending everything to
resource "aws_key_pair" "admin" {
  key_name   = "admin-keyfor-lab07"
  public_key = file(var.path_to_ssh_public_key)
}

# Local block
# The block has local variables that should not be exposed anywhere else
# Its just internal to this file
locals {
  vms = {
    foo_app = {},
    foo_db  = {}
  }
  allowed_cidrs_for_db = var.allow_all_ip_addresses_to_access_database_server ? ["0.0.0.0/0"] : ["${var.my_ip_address}/32"]
}

# Another resource block -- EC2 instance resource block
resource "aws_instance" "servers" {
  for_each = local.vms

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  key_name        = aws_key_pair.admin.key_name
  security_groups = [aws_security_group.vms.name]

  tags = {
    Name = "${each.key} server for Alpine_Inc"
  }
}

# Resource -- securty group rules
resource "aws_security_group" "vms" {
  name = "vms_for_Alpine_Inc"

  # SSH
  ingress {
    from_port   = 0
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP in
  ingress {
    from_port   = 0
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # PostgreSQL in ----- Databse server
  ingress {
    from_port   = 0
    to_port     = 5432 # Default port for databse 
    protocol    = "tcp"
    cidr_blocks = local.allowed_cidrs_for_db
  }

  # HTTPS out
  egress {
    from_port   = 0
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Output block
output "vm_public_addresses" {
  value = { for role_name, vm in aws_instance.servers : role_name => {
    public_hostname   = vm.public_dns,
    public_ip_address = vm.public_ip
    }
  }
}
