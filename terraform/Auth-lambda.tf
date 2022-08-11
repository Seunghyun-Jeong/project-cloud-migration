// 람다의 함수 안에 들어갈 타입 'zip', 소스 디렉토리가 어딨는지, 그 소스 디렉토리를 zip파일로 만들어서 어디에 나둘 것인지 

data "archive_file" "lambda_my_function" {
  type             = "zip"
  source_dir       = "${path.module}/../auth-lambda/authorizer"
  output_path      = "${path.module}/auth-lambda.js.zip"

}
// 람다 함수를 만들자. 경로를 적고 파일 이름을 적어줘야함, 람다 함수 이름지정, role =역할 밑에 가면 role 리소스가 있다. 핸들러.핸들러로 해줘야 함
// 그리고 source_code_hash는 들어가서 보면 저런 filebase 번호 몇번 쓴다 이런거 찾아볼 수 있음. 그리고 zip 파일의 경로 지정을 해주면 찾아서 클라우드에 업로드함.
// 런타임 지정 필수. environment 안에 환경변수 넣어주면 바로 들어감. 그렇지만 이 코드 그대로 git에 올릴 수는 없기때문에 재찬님의 환경변수 코드 사용 방법을 보면 된다.

resource "aws_lambda_function" "auth_lambda" {
  # If the file is not in the current working directory you will need to include a 
  # path.module in the filename.
  filename      = "./auth-lambda.js.zip"
  function_name = "auth-lambda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "handler.handler"


  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  
  // 처음 plan할 경우 바로 아랫줄은 주석 처리 할것. .zip 파일 만들어진게 없어서 에러뜸
  source_code_hash = filebase64sha256("./auth-lambda.js.zip")

  runtime = "nodejs14.x"

#   environment {
#     variables = {
#     HOSTNAME: 
#     USERNAME: 
#     PASSWORD: 
#     DATABASE: 
#     
#     }
#   }
}

// 람다 이용시, cloudwatch를 이용하고 싶다면 만들어 줘야 하는 부분.
// 위에 있는 람다 이름을 찾아서 지정해줘야 함. 람다함수의 이름이 바뀌어도 람다의 이름이 들어가기 때문에 cloudwatch log group인지 알 수 있음.

resource "aws_cloudwatch_log_group" "lambda-logs" {
  name              = "/aws/lambda/${aws_lambda_function.auth_lambda.function_name}"
  retention_in_days = 14
}


// role = 역할 policy = 정책
// 정책이 모여서 역할이 된다.

resource "aws_iam_role" "iam_for_lambda" { //정책이 모여서 역할이 됨
  name = "auth-lambda"
//이 밑에서 뼈대가 되는 정책을 적용해 준다.
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

// 위의 뼈대를 건들이지 않고, 새로운 정책을 추가하겠다.
// sns의 정책을 추가하고 싶었는데, role에 추가할 땐 계속 오류가 났다. policy쪽에 꼭 만들어줘야 함
// 람다의 구성-권한에 가서 리소스별로 먼저 보고, 그 후에 '역할 문서 보기'를 누르면 필요한 부분만 가지고 오면 된다.
// 모르겠으면 매니지먼트 콘솔로 먼저 만들어 볼 것!

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

// attachment = 부착하다 policy(정책)를 role(역할)에 추가하고 싶다.
// role의 이름, policy_arn을 지정해주면 연결된다.

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

# Attach API Gateway to Lambda 

// 퍼미션을 적어주면 람다의 앞쪽 트리거로 붙게 된다.
// 건드릴 부분은 function_name을 원하는 람다의 arn으로 지정 해주면 된다.

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auth_lambda.arn
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.http-api.arn}/*"
}
