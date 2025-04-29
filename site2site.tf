# Fetch available AZs dynamically
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "main-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-vpc-igw"
  }
}

# Public Subnet 1
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 1) # dynamically calculated
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "main-vpc-public-1"
  }
}

# Public Subnet 2
resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 2)
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "main-vpc-public-2"
  }
}

# Private Subnet 1
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 101)
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "main-vpc-private-1"
  }
}

# Private Subnet 2
resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 102)
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "main-vpc-private-2"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "main-vpc-public-rt"
  }
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-vpc-private-rt"
  }
}

# Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}

# Customer Gateway (on-premises side)
resource "aws_customer_gateway" "example" {
  bgp_asn    = 65000
  ip_address = var.customer_gateway_ip  # Use the variable here
  type       = "ipsec.1"

  tags = {
    Name = "OnPrem-Customer-Gateway"
  }
}


# Virtual Private Gateway (VGW)
resource "aws_vpn_gateway" "example" {
  vpc_id = aws_vpc.main.id
}

# VPN Connection
resource "aws_vpn_connection" "example" {
  customer_gateway_id = aws_customer_gateway.example.id
  vpn_gateway_id      = aws_vpn_gateway.example.id
  type                = "ipsec.1"
  static_routes_only  = true
}

# VPN Connection Static Route (to on-premises)
resource "aws_vpn_connection_route" "example" {
  vpn_connection_id      = aws_vpn_connection.example.id
  destination_cidr_block = var.on_prem_cidr
}

# Route Table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

 # Route to on-premises via VPN (dynamic)
  route {
    cidr_block = var.on_prem_cidr
    gateway_id = aws_vpn_gateway.example.id
  }

  tags = {
    Name = "main-vpc-main-rt"
  }
}

# Outputs
output "vpn_connection_id" {
  value = aws_vpn_connection.example.id
}

output "customer_gateway_id" {
  value = aws_customer_gateway.example.id
}

output "vpn_gateway_id" {
  value = aws_vpn_gateway.example.id
}

output "vpc_id" {
  value = aws_vpc.main.id
}
