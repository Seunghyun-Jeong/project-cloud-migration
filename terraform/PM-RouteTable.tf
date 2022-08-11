# // 인터넷 게이트웨이
# resource "aws_internet_gateway" "igw" {
#   vpc_id = aws_vpc.PM-VPC.id

#   tags = {
#     Name = "PM_internetgateway"
#   }
# }

// Route Table 생성
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.PM-VPC.id

  tags = {
    Name = "PM_RouteTable1"
  }
}


// Route Table 생성
resource "aws_route_table" "route_table2" {
  vpc_id = aws_vpc.PM-VPC.id

  tags = {
    Name = "PM_RouteTable2"
  }
}

resource "aws_route_table_association" "route_table_association_1" {
  subnet_id      = aws_subnet.PM-VPC_private_subnet1.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "route_table_association_2" {
  subnet_id      = aws_subnet.PM-VPC_private_subnet2.id
  route_table_id = aws_route_table.route_table2.id
}

# resource "aws_route_table" "route_table2" {
#   vpc_id = aws_vpc.PM-VPC.id

#   tags = {
#     Name = "PM_RouteTable2"
#   }
# }
# resource "aws_route_table_association" "route_table_association_2" {
#   subnet_id      = aws_subnet.PM-VPC_private_subnet2.id
#   route_table_id = aws_route_table.route_table2.id
# }