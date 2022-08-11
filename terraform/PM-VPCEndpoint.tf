resource "aws_vpc_endpoint" "ecr-api" {
  vpc_id            = aws_vpc.PM-VPC.id
  service_name      = "com.amazonaws.ap-northeast-2.ecr.api"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.defaultsg.id,
    aws_security_group.sg.id,
  ]
  subnet_ids        = [
    aws_subnet.PM-VPC_private_subnet1.id,
    aws_subnet.PM-VPC_private_subnet2.id
  ]
  tags  = {
    Name = "ECR-API"
  }
  
}


resource "aws_vpc_endpoint" "ecr-dkr" {
  vpc_id            = aws_vpc.PM-VPC.id
  service_name      = "com.amazonaws.ap-northeast-2.ecr.dkr"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.defaultsg.id,
    aws_security_group.sg.id,
  ]
  subnet_ids        = [
    aws_subnet.PM-VPC_private_subnet1.id,
    aws_subnet.PM-VPC_private_subnet2.id
  ]
  tags  = {
    Name = "ECR-DKR"
  }
}

resource "aws_vpc_endpoint" "SSM" {
  vpc_id            = aws_vpc.PM-VPC.id
  service_name      = "com.amazonaws.ap-northeast-2.ssm"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.defaultsg.id,
    aws_security_group.sg.id,
  ]
  subnet_ids        = [
    aws_subnet.PM-VPC_private_subnet1.id,
    aws_subnet.PM-VPC_private_subnet2.id
  ]
  tags  = {
    Name = "SSM"
  }
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id            = aws_vpc.PM-VPC.id
  service_name      = "com.amazonaws.ap-northeast-2.logs"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.defaultsg.id,
    aws_security_group.sg.id,
  ]
  subnet_ids        = [
    aws_subnet.PM-VPC_private_subnet1.id,
    aws_subnet.PM-VPC_private_subnet2.id
  ]
  tags  = {
    Name = "CloudWatch logs"
  }
}


data "aws_vpc_endpoint_service" "s3" {

  service      = "s3"
  service_type = "Gateway"

}

# Create a VPC endpoint
resource "aws_vpc_endpoint" "s3-ep" {
  vpc_id       = aws_vpc.PM-VPC.id
  service_name = "com.amazonaws.ap-northeast-2.s3"

  tags  = {
    Name = "S3"
  }
}

//endpoint route table 연결하기 (gateway로 만드는건 라우팅 테이블 필요. igw-RouteTable.tf에서 만듦)
resource "aws_vpc_endpoint_route_table_association" "s3_vpce_t1" {
  route_table_id  = aws_route_table.route_table.id
  vpc_endpoint_id = aws_vpc_endpoint.s3-ep.id
}

resource "aws_vpc_endpoint_route_table_association" "s3_vpce_t2" {
  route_table_id  = aws_route_table.route_table2.id
  vpc_endpoint_id = aws_vpc_endpoint.s3-ep.id
}

data "aws_vpc_endpoint_service" "dynamodb" {

  service      = "dynamodb"
  service_type = "Gateway"

}

# Create a VPC endpoint
resource "aws_vpc_endpoint" "dynamodb-ep" {
  vpc_id       = aws_vpc.PM-VPC.id
  service_name = "com.amazonaws.ap-northeast-2.dynamodb"

  tags  = {
    Name = "dynamodb"
  }
}


resource "aws_vpc_endpoint_route_table_association" "dynamo_vpce_t1" {
  route_table_id  = aws_route_table.route_table.id
  vpc_endpoint_id = aws_vpc_endpoint.dynamodb-ep.id
}


resource "aws_vpc_endpoint_route_table_association" "dynamo_vpce_t2" {
  route_table_id  = aws_route_table.route_table2.id
  vpc_endpoint_id = aws_vpc_endpoint.dynamodb-ep.id
}