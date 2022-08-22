//vpc link PM 생성
resource "aws_apigatewayv2_vpc_link" "vpclink_PM" {
  name        = "vpclink_PM"
  security_group_ids = [aws_security_group.sg.id]
  subnet_ids = [
        aws_subnet.PM-VPC_private_subnet1.id,
        aws_subnet.PM-VPC_private_subnet2.id
  ]
}

//vpc link User 생성
resource "aws_apigatewayv2_vpc_link" "vpclink_UserAuth" {
  name        = "vpclink_UserAuth"
  security_group_ids = [aws_security_group.privateSG01.id]
  subnet_ids = [
        aws_subnet.privateSubnet1.id,
        aws_subnet.privateSubnet2.id
  ]
}

//http-api gateway 생성
resource "aws_apigatewayv2_api" "http-api" {
  name          = "http-api"
  protocol_type = "HTTP"
}



//  POST /product 통합
resource "aws_apigatewayv2_integration" "apigw_integration-product-post" {
  api_id           = aws_apigatewayv2_api.http-api.id
  integration_type = "HTTP_PROXY"
  integration_uri  = aws_lb_listener.terramino.arn

  integration_method = "POST"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.vpclink_PM.id
  payload_format_version = "1.0"
  depends_on      = [aws_apigatewayv2_vpc_link.vpclink_PM,  
                    aws_lb_listener.terramino]
}

//  GET /product 통합

resource "aws_apigatewayv2_integration" "apigw_integration-product-get" {
  api_id           = aws_apigatewayv2_api.http-api.id
  integration_type = "HTTP_PROXY"
  integration_uri  = aws_lb_listener.terramino.arn

  integration_method = "GET"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.vpclink_PM.id
  payload_format_version = "1.0"
  depends_on      = [aws_apigatewayv2_vpc_link.vpclink_PM,  
                    aws_lb_listener.terramino]
}

//  GET /user 통합
resource "aws_apigatewayv2_integration" "apigw_integration-user-get" {
  api_id           = aws_apigatewayv2_api.http-api.id
  integration_type = "HTTP_PROXY"
  integration_uri  = aws_service_discovery_service.namespace-service.arn

  integration_method = "GET"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.vpclink_UserAuth.id
  payload_format_version = "1.0"
  depends_on      = [aws_apigatewayv2_vpc_link.vpclink_UserAuth]
}

// POST /user/login,signup 통합
resource "aws_apigatewayv2_integration" "apigw_integration-user-post" {
  api_id           = aws_apigatewayv2_api.http-api.id
  integration_type = "HTTP_PROXY"
  integration_uri  = aws_service_discovery_service.namespace-service.arn

  integration_method = "POST"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.vpclink_UserAuth.id
  payload_format_version = "1.0"
  depends_on      = [aws_apigatewayv2_vpc_link.vpclink_UserAuth]
}


# API GW route with ANY method
// POST /product 경로 생성
resource "aws_apigatewayv2_route" "POST-product" {
  api_id    = aws_apigatewayv2_api.http-api.id
  route_key = "POST /product"
  target = "integrations/${aws_apigatewayv2_integration.apigw_integration-product-post.id}"
  authorization_type = "CUSTOM"
  authorizer_id = aws_apigatewayv2_authorizer.lambda-GW-auth.id
  depends_on  = [aws_apigatewayv2_integration.apigw_integration-product-post]
}

// GET /product 경로 생성
resource "aws_apigatewayv2_route" "GET-product" {
  api_id    = aws_apigatewayv2_api.http-api.id
  route_key = "GET /product"
  target = "integrations/${aws_apigatewayv2_integration.apigw_integration-product-get.id}"
  authorization_type = "CUSTOM"
  authorizer_id = aws_apigatewayv2_authorizer.lambda-GW-auth.id
  depends_on  = [aws_apigatewayv2_integration.apigw_integration-product-get]
}



// GET /user 경로 생성
resource "aws_apigatewayv2_route" "GET-user" {
  api_id    = aws_apigatewayv2_api.http-api.id
  route_key = "GET /user"
  target = "integrations/${aws_apigatewayv2_integration.apigw_integration-user-get.id}"
  depends_on  = [aws_apigatewayv2_integration.apigw_integration-user-get]
}

// POST /user/login 경로 생성
resource "aws_apigatewayv2_route" "GET-user-login" {
  api_id    = aws_apigatewayv2_api.http-api.id
  route_key = "POST /user/login"
  target = "integrations/${aws_apigatewayv2_integration.apigw_integration-user-post.id}"
  depends_on  = [aws_apigatewayv2_integration.apigw_integration-user-post]
}


// POST /user/signup 경로 생성
resource "aws_apigatewayv2_route" "GET-user-signup" {
  api_id    = aws_apigatewayv2_api.http-api.id
  route_key = "POST /user/signup"
  target = "integrations/${aws_apigatewayv2_integration.apigw_integration-user-post.id}"
  depends_on  = [aws_apigatewayv2_integration.apigw_integration-user-post]
}

// 람다 권한 부여자 설정
resource "aws_apigatewayv2_authorizer" "lambda-GW-auth" {
  api_id           = aws_apigatewayv2_api.http-api.id
  authorizer_type  = "REQUEST"
  authorizer_uri   = aws_lambda_function.auth_lambda.invoke_arn
  authorizer_credentials_arn = aws_iam_role.invocation_role.arn
  identity_sources = ["$request.header.authorization"]
  name             = "Lambd-Auth"
  authorizer_result_ttl_in_seconds = 1
  authorizer_payload_format_version = "2.0"

}

resource "aws_iam_role" "invocation_role" {
  name = "api_gateway_auth_invocation"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "invocation_policy" {
  name = "default"
  role = aws_iam_role.invocation_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "lambda:InvokeFunction",
      "Effect": "Allow",
      "Resource": "${aws_lambda_function.auth_lambda.arn}"
    }
  ]
}
EOF
}




# Set a default stage
resource "aws_apigatewayv2_stage" "apigw_stage" {
  api_id = aws_apigatewayv2_api.http-api.id
  name   = "$default"
  auto_deploy = true
  depends_on  = [aws_apigatewayv2_api.http-api]
}
