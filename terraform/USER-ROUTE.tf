# route table with target as internet gateway
resource "aws_route_table" "IG_route_table" {
  depends_on = [
    aws_vpc.vpc,
    aws_internet_gateway.testIGW,
  ]

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.testIGW.id
  }

  tags = {
    Name = "IG-route-table"
  }
}

# associate route table to public subnet
resource "aws_route_table_association" "associate_routetable_to_public_subnet" {
  depends_on = [
    aws_subnet.publicSubnet1,
    aws_route_table.IG_route_table,
  ]
  subnet_id      = aws_subnet.publicSubnet1.id
  route_table_id = aws_route_table.IG_route_table.id
}

# route table with target as NAT gateway
resource "aws_route_table" "NAT_route_table" {
  depends_on = [
    aws_vpc.vpc,
    aws_nat_gateway.testNAT,
  ]

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.testNAT.id
  }

  tags = {
    Name = "NAT-route-table"
  }
}

# associate route table to private subnet
resource "aws_route_table_association" "associate_routetable_to_private_subnet" {
  depends_on = [
    aws_subnet.privateSubnet1,
    aws_subnet.privateSubnet2,
    aws_route_table.NAT_route_table,
  ]
  subnet_id      = aws_subnet.privateSubnet1.id
  route_table_id = aws_route_table.NAT_route_table.id
}