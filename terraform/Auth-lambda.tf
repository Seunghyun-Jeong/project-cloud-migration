data "archive_file" "lambda_my_function" {
  type             = "zip"
  source_dir       = "${path.module}/../auth-lambda/authorizer"
  output_path      = "${path.module}/auth-lambda.js.zip"

}

resource "aws_lambda_function" "auth_lambda" {
  filename      = "./auth-lambda.js.zip"
  function_name = "auth-lambda"
  role          = aws_iam_role.lambda.arn
  handler       = "handler.handler"


  // 처음 plan할 경우 바로 아랫줄은 주석 처리 할것. .zip 파일 만들어진게 없어서 에러뜸
  # source_code_hash = filebase64sha256("./auth-lambda.js.zip")

  runtime = "nodejs14.x"

  environment {
    variables = "${var.JWT_SECRET_lambda}"
  }

}


resource "aws_cloudwatch_log_group" "lambda-logs" {
  name              = "/aws/lambda/${aws_lambda_function.auth_lambda.function_name}"
  retention_in_days = 14
}


resource "aws_iam_role" "lambda" {
  name = "auth-lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_iam_policy" "lambda_logging" { 
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:ap-northeast-2:{aws계정ID}:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:ap-northeast-2:{aws계정ID}:log-group:/aws/lambda/auth:*"
            ]
        }
    ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_iam_role_policy_attachment" "lambda_api" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_api2" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayAdministrator"
}