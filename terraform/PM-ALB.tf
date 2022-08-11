// ALB 만들기
resource "aws_lb" "terramino" {
  name               = "alb-PM"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets            = [aws_subnet.PM-VPC_private_subnet1.id, aws_subnet.PM-VPC_private_subnet2.id]

    tags = {
    Name = "aws_lb"
  }
}

// ALB 리스너 만들기
resource "aws_lb_listener" "terramino" {
  load_balancer_arn = aws_lb.terramino.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.terramino.arn
  }

}

// 로드밸런서 타겟그룹 만들기
resource "aws_lb_target_group" "terramino" {
   name         = "asg-80"
   port         = 80
   protocol     = "HTTP"
   target_type  = "ip"
   vpc_id       = aws_vpc.PM-VPC.id

    tags = {
    Name = "aws_lb_target_group"
  }
 }