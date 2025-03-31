# The goal here is to keep the code compact, which inevitably leads
# to some tradeoffs between code complexity and flexibily.
#
# For exxample, Public and private subnets will be assigned to all AZs
# in cyclic manner, should their number be grater than the possible AZs.
# 
# However, the first Public and private subnets will 
# both be assigned to the first AZ ... so on and so forth


# VPC
resource "aws_vpc" "main-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}

# Public subnets 
resource "aws_subnet" "public" {
  for_each          = var.subnets["public"]
  vpc_id            = aws_vpc.main-vpc.id
  cidr_block        = each.value
  availability_zone = var.availability_zones[index(keys(var.subnets["public"]), each.key)]
  
  tags = {
    Name = each.key
  }
}

# Private subnets 
resource "aws_subnet" "private" {
  for_each          = var.subnets["private"]
  vpc_id            = aws_vpc.main-vpc.id
  cidr_block        = each.value
  availability_zone = var.availability_zones[index(keys(var.subnets["private"]), each.key)]
  
  tags = {
    Name = each.key
  }
}

# Internet Gateway for the public subnet
resource "aws_internet_gateway" "igw" {
  tags = {
    Name = "igw"
  }
  vpc_id = aws_vpc.main-vpc.id
}

# Elastipc IP for the NAT Gateway
# Here, the private address is  specified to avoid being assigned one 
# in the NAT Gateway's public block
resource "aws_eip" "nat-gw-eip" {
  associate_with_private_ip = local.nat_gw_private_ip
  depends_on                = [aws_internet_gateway.igw]
}

# Define NAT Gateway in one of the public subnets. In total there is:
# - one public subnet for NAT gateway
# - one public subnet for jump station
# - the rest of the public subnets can host DMZ services
#
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat-gw-eip.id
  subnet_id     = aws_subnet.public[local.nat_gw_pub_subnet].id

  tags = {
    Name = "nat-gw"
  }
  depends_on = [aws_eip.nat-gw-eip]
}

# Route tables for the subnets
resource "aws_route_table" "route-tables" {
  for_each = { 
    public  = "public-route-table"
    private = "private-route-table" 
  }

  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = each.value
  }
}

# Route  public subnet traffic through the Internet Gateway
resource "aws_route" "public-internet-igw-route" {
  route_table_id         = aws_route_table.route-tables["public"].id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

# Route private subnet traffic through the NAT Gateway
resource "aws_route" "nat-ngw-route" {
  route_table_id         = aws_route_table.route-tables["private"].id
  gateway_id              = aws_nat_gateway.nat-gw.id
  destination_cidr_block = "0.0.0.0/0"
}

# Public subnet route table associations
resource "aws_route_table_association" "public" {
  for_each      = aws_subnet.public
  route_table_id = aws_route_table.route-tables["public"].id
  subnet_id      = each.value.id
}

# Private subnet route table associations
resource "aws_route_table_association" "private" {
  for_each      = aws_subnet.private
  route_table_id = aws_route_table.route-tables["private"].id
  subnet_id      = each.value.id
}