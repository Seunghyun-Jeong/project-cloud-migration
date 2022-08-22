// default 보안그룹
resource "aws_security_group" "defaultsg" {
  vpc_id = "${aws_vpc.PM-VPC.id}"     #생성할 위치의 VPC ID
  name = "d-efault"    # default 이름은 예약되어있더라고요
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1" # 모든 트래픽
    self = true
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1" 
    cidr_blocks = ["0.0.0.0/0"]
  }
}


// 보안그룹 프라이빗
resource "aws_security_group" "sg" {
  vpc_id = "${aws_vpc.PM-VPC.id}"     #생성할 위치의 VPC ID
  name = "ECS-service"                        #그룹 이름
  description = "Terraform WEB SG"    #설명
  ingress {
    from_port = 22                    #인바운드 시작 포트
    to_port = 22                      #인바운드 끝나는 포트
    protocol = "tcp"                  #사용할 프로토콜
    cidr_blocks = ["0.0.0.0/0"]       #허용할 IP 범위
}
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
 ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
    tags = {
    Name = "allow_tls"
  }
}