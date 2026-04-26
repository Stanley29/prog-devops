terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

# Default VPC
data "aws_vpc" "default" {
  default = true
}

# Вибираємо ОДИН default subnet — перший у списку
data "aws_subnets" "default" {
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

locals {
  default_subnet_id = data.aws_subnets.default.ids[0]
}
