# 사내 정보 시스템
terraform을 사용해서 프로젝트에서 필요한 사내 정보 시스템 aws 스택이 생성된 후 필요한 작업입니다.

## Deployment Instructions

이제 퍼블릭 EC2에서 프라이빗 EC2로 접속이 필요합니다.

그러기 위해서는 기존 자신의 키페어를 `scp` 명령어를 이용해서 퍼블릭 EC2에 복사해 줍니다.

`scp -i /Users/키페어의 위치한 경로/키페어 키페어 본인의 퍼블릭EC2 엔드포인트:/퍼블릭EC2에 키페어를 저장할 경로`

본인의 터미널 또는 우분투에 있는 키페어가 제대로 복사 되었으면 이제 프라이빗 EC2에 접속해 줍니다.

접속한 프라이빗 EC2는 아직 어떤한 데이터도 없는 상태입니다.

두 가지의 작업이 필요합니다.

공식 문서를 통헤서 mysql을 설치가 필요합니다.

사내 정보 시스템을 가져오기 위해서 이 리포지토리(Repository)를 프라이빗 EC2에 GitHub를 통해서 복제 합니다. 

- mysql 설치 https://dev.mysql.com/doc/mysql-shell/8.0/en/mysql-shell-install-linux-quick.html
- Git   설치 https://git-scm.com/book/en/v2/Getting-Started-Installing-Git

mysql 과 Git이 제대로 설치되었는지 확인하려면 `mysql --version`, `Git --version` 명령어를 사용합니다.

이제 복제된 리포지토리(Repository)된 폴더 중 uer-API폴더에 있는 aacompany_dump.sql파일을 덤프(dump)해 줍니다.

## main README.md로 옮길 내용

1. USER-EC2.tf 파일에서 `key_name` 부분에 자신의 케페어를 작성해 줍니다

1. terraform 명령어를 통해 aws 스택을 생성 합니다.

1. `terraform init` `terraform plan` `terraform apply`

```jsx
# user-ec2.tf
resource "aws_instance" "USEREC201" {
  ami                          = "ami-063db2954fe2eec9f"
  instance_type                = "t2.micro"
  subnet_id                    = aws_subnet.publicSubnet1.id
  key_name                     = "[본인의 키페어]"
  associate_public_ip_address  = "true"
  vpc_security_group_ids = [
    aws_security_group.publicSG01.id
  ]
  root_block_device {
    volume_size = 8
    volume_type = "gp2"
    tags = {
      "Name" = "public-ec2-01-vloume-1"
    }
  }

  tags = {
    "Name" = "Bastion Host"
  }
}

resource "aws_instance" "USEREC202" {
  ami                          = "ami-063db2954fe2eec9f"
  instance_type                = "t2.micro"
  subnet_id                    = aws_subnet.privateSubnet1.id
  key_name                     = "[본인의 키페어]"
  vpc_security_group_ids = [
    aws_security_group.privateSG01.id
  ]
  root_block_device {
    volume_size = 8
    volume_type = "gp2"
    tags = {
      "Name" = "private-ec2-01-vloume-1"
    }
  }

  tags = {
    "Name" = "user-ec2"
  }
}
```
