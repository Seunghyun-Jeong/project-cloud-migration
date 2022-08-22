resource "aws_instance" "USEREC201" {
  ami                          = "ami-063db2954fe2eec9f"
  instance_type                = "t2.micro"
  subnet_id                    = aws_subnet.publicSubnet1.id
  key_name                     = "{본인의 키페어}"
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
  key_name                     = "{본인의 키페어}"
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