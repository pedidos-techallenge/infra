provider "aws" {
  region  = "us-east-1"
}

terraform {
  backend "s3" {}
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "techchallenge-vpc"
  }
}
# Public Subnets - 10.0.0.0/24 and 10.0.1.0/24
resource "aws_subnet" "public" {
  count      = 2
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.${count.index}.0/24"
  availability_zone       = element(["us-east-1a", "us-east-1b"], count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-public"
  }
}

# Private Subnets - 10.0.2.0/24 and 10.0.3.0/24
resource "aws_subnet" "private" {
  count      = 2
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.${count.index + 2}.0/24"
  map_public_ip_on_launch = false
  availability_zone       = element(["us-east-1a", "us-east-1b"], count.index)

  tags = {
    Name = "subnet-private"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "techchallenge-igw"
  }
}

# Route Table for public subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public-route-table"
  }
}

# Route for IGW
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Link the public subnet to route table
resource "aws_route_table_association" "public_rt_association" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name = "ApplicationEntry"
}

# API Gateway Resource
resource "aws_api_gateway_resource" "application_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "pedidos"
}