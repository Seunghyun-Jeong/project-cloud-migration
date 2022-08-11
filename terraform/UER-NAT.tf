resource "aws_eip" "nat-eip" {
  vpc              = true
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_nat_gateway" "testNAT" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.publicSubnet1.id

  tags = {
    Name = "project4-NATgw"
  }
}

