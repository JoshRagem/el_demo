terraform {
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Name      = "el_demo"
      ManagedBy = "terraform"
    }
  }
  assume_role {
    role_arn     = var.tf_role_arn
    session_name = "whc.api.provider.aws"
    policy       = <<-EOF
      {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Effect": "Allow",
            "Action": [
              "iam:*",
              "ec2:*",
              "acm:*",
              "ecs:*",
              "elasticloadbalancing:*",
              "logs:*",
              "route53:*",
              "rds:*",
              "secretsmanager:*"
            ],
            "Resource": "*"
          }
        ]
      }
    EOF
  }
}

locals {
  public_cidr_blocks = [
    cidrsubnet(var.subnet_cidr_block, 3, 0),
    cidrsubnet(var.subnet_cidr_block, 3, 1),
    cidrsubnet(var.subnet_cidr_block, 3, 2),
    cidrsubnet(var.subnet_cidr_block, 3, 3)
  ]
}

resource "aws_vpc" "el_demo" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_internet_gateway" "el_demo" {
  vpc_id = aws_vpc.el_demo.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.el_demo.id
}

resource "aws_route" "public_default" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.el_demo.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public" {
  count = length(var.availability_zones)

  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public[count.index].id
}

resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.el_demo.id
  cidr_block        = local.public_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    SubnetType = "public"
  }
}

resource "aws_security_group" "vpc_endpoints" {
  name_prefix = "vpc-endpoints."
  description = "Default security group for VPC endpoints"

  vpc_id = aws_vpc.el_demo.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "subnet_ingress" {
  type              = "ingress"
  description       = "VPC endpoint subnet ingress"
  security_group_id = aws_security_group.vpc_endpoints.id
  cidr_blocks       = local.public_cidr_blocks
  from_port         = 0
  to_port           = 0
  protocol          = -1
}

resource "aws_security_group_rule" "internet_access" {
  type              = "egress"
  description       = "Internet access"
  security_group_id = aws_security_group.vpc_endpoints.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = -1
}

locals {
  vpc_interface_endpoints = toset(["secretsmanager"])
}

resource "aws_vpc_endpoint" "interface_endpoint" {
  for_each = local.vpc_interface_endpoints

  vpc_id            = aws_vpc.el_demo.id
  service_name      = "com.amazonaws.${var.aws_region}.${each.key}"
  vpc_endpoint_type = "Interface"

  subnet_ids         = aws_subnet.public.*.id
  security_group_ids = [aws_security_group.vpc_endpoints.id]

  private_dns_enabled = true

  tags = {
    Name = "el_demo.${each.key}"
  }
}
