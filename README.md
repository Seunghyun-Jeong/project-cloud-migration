# Cloud Migration

클라우드 마이그레이션이 점진적으로 진행될 예정이기 때문에, 이 문서에서는 모놀리틱에서 제품 관리팀의 API 서버만 별도의 컨테이너 기반의 클러스터에 이관합니다.

모놀리틱으로 구현된 사내 정보 시스템의 인증을 거치고 있습니다.

![제목 없는 다이어그램-페이지-1](https://user-images.githubusercontent.com/103630651/184686524-264d0bc4-3f04-492e-9242-899d906c6e12.jpg)


---

# ****Requirements****

- [AWS 계정](https://portal.aws.amazon.com/gp/aws/developer/registration/index.html)이 아직 없는 경우 생성하고 로그인합니다. 사용하는 IAM 사용자는 필요한 AWS 서비스를 호출하고 AWS 리소스를 관리할 수 있는 충분한 권한이 있어야 합니다.
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) 설치 및 구성
- [Git Installed](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- Docker 설치 필요 
[https://docs.docker.com/engine/install/](https://docs.docker.com/engine/install/)
- 테라폼 설치 필요
[https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started)

---

# ****Deployment Instructions****

1. 새 폴더를 만들고 , 터미널에서 해당 폴더로 이동한 다음 GitHub 리포지토리를 복제합니다.

```jsx
git clone https://github.com/cs-devops-bootcamp/devops-02-Final-TeamC-scenario2.git
```

1. 복제한 폴더에 들어가서, terraform 폴더로 한 번 더 들어갑니다.

1. Auth-lambda 파일에서 계정 ID 부분에 자신의 계정을 기재하시면 됩니다.

```jsx
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
```

PM-ECS 파일에서도 마찬가지로 계정 ID 부분에 자신의 계정을 기재하시면 됩니다.

```jsx
resource "aws_iam_policy" "policy" {
  name        = "systemManager"
  description = "A test policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue",
                "kms:Decrypt",
                "ssm:GetParametersByPath",
                "ssm:GetParameters",
                "ssm:GetParameter"
            ],
            "Resource": [
                "arn:aws:ssm:ap-northeast-2:{aws계정ID}:*",
                "arn:aws:secretsmanager:ap-northeast-2:{aws계정ID}::*",
                "arn:aws:kms:ap-northeast-2:{aws계정ID}:*"
            ]
        }
    ]
}
EOF
}

```

1. terraform 폴더에서 명령어를 사용합니다.
`terraform init`
    
    `terraform apply`
    

→ apply 사용시, aws 스택이 생성됩니다.

5. user-API README.md, product-API README.md 참조

## API Gateway Endpoint 사용법

Postmen으로 API Gateway의 엔드포인트로 **Request 보내는 방법**

1. POST /user/login

```
**request**

{
  "loginname": "kimcoding",
  "password": "qwerty"
}
```

1. POST /user/signup

```
**request**

{
  "loginname": "kimjava",
  "password": "supersecret",
  "name": "김자바"
}
```

1. GET /user
→ **POST /user/login**을 통해 받은 **bearer token** 입력하고 send를 누르면 
**Responses**를 받을 수 있습니다.

1. POST /product
**POST /user/login**을 통해 받은 **bearer token** 입력 후 하단의 내용을 body값으로 입력합니다.

```
**request**

{
  "id": 1,
  "name": "캘리포니아산 사과",
  "price": 599000,
  "description": "800만 화소의 5G를 지원하는 맛있는 사과"
}
```

1. GET /product
→ **POST /user/login**을 통해 받은 **bearer token** 입력하고 send를 누르면 
**Responses**를 받을 수 있습니다.

---

# ****Cleanup****

1. ECR 이미지 삭제
2. `terraform destroy`
