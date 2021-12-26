resource "aws_vpc" "vpc" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    budget  = "network"
    project = "magma"
    Name    = var.name
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.vpc.id
  count             = length(var.public_subnets)
  cidr_block        = var.public_subnets[count.index].cidr_block
  availability_zone = var.public_subnets[count.index].zone

  map_public_ip_on_launch = true

  depends_on = [
    aws_vpc.vpc
  ]

  tags = {
    budget  = "network"
    project = "magma"
    Name    = var.public_subnets[count.index].name
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  depends_on = [
    aws_vpc.vpc
  ]

  tags = {
    budget  = "network"
    project = "magma"
    Name    = "Internet Gateway"
  }
}

resource "aws_default_route_table" "rt" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }
}

resource "aws_route_table_association" "rt_assoc" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_default_route_table.rt.id
}
