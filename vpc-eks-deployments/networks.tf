# Create VPC 
resource "aws_vpc" "t-vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "VPC: TitoVPC"
  }
}


# Create Public Subnet
resource "aws_subnet" "public_subnet" {
  count = length(var.cidr_public_subnet)
  vpc_id = aws_vpc.t-vpc.id
  cidr_block = element(var.cidr_public_subnet, count.index)
  map_public_ip_on_launch = true
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "Public Subnet ${count.index + 1}"
  }
}

# Create Private Subnet
resource "aws_subnet" "private_subnet" {
  count = length(var.cidr_private_subnet)
  vpc_id = aws_vpc.t-vpc.id
  cidr_block = element(var.cidr_private_subnet, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "Private Subnet ${count.index + 1}"
  }
}

# Create internet Gateway
resource "aws_internet_gateway" "public_igw" {
  vpc_id = aws_vpc.t-vpc.id

  tags = {
    Name = "IGW for Public Subnet"
  }
}

# Create Route Table to make the Public Subnet become Public using IGW
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.t-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_igw.id
  }

  tags = {
    Name = "Route Table (Public Sub)"
  }
}

# Create Route Table Association for the Public Subnets
resource "aws_route_table_association" "public_subnet_asso" {
  count = length(var.cidr_public_subnet)
  subnet_id = element(aws_subnet.public_subnet[*].id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}



# Create EIP for Private Subnet
resource "aws_eip" "nat_eip" {
  count = length(var.cidr_private_subnet)
  vpc = true
}

# Create NAT Gateway for Private Subnet
resource "aws_nat_gateway" "nat_gateway" {
  count = length(var.cidr_private_subnet)
  depends_on = [aws_eip.nat_eip]
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id = aws_subnet.private_subnet[count.index].id

  tags = {
    Name = "Private NAT GW"
  }
}
