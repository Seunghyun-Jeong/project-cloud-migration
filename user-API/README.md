# 사내 정보 시스템
프로젝트에서 필요한 사내 정보 시스템을 구축합니다.

## Deployment Instructions

1. USER-EC2.tf 파일에서 `key_name` 부분에 자신의 케페어를 작성해 줍니다

1. terraform 명령어를 통해 구축합니다.

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
