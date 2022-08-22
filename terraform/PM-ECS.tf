resource "aws_cloudwatch_log_group" "log" {
  name = "/aws/task/${aws_ecs_task_definition.ecs_taskdef.id}"
}


resource "aws_ecs_cluster" "ECS-cluster" {
  name = "PM-DynamoDB"


  configuration {
    execute_command_configuration {
        logging    = "OVERRIDE"
      log_configuration {
        cloud_watch_log_group_name    = aws_cloudwatch_log_group.log.name
      }
    }
   }
}



//ecs service 생성
resource "aws_ecs_service" "demo-ecs-service" {
  name            = "PM-DynamoDB-SV"
  cluster         = aws_ecs_cluster.ECS-cluster.id
  task_definition = aws_ecs_task_definition.ecs_taskdef.arn
  desired_count   = 1
  deployment_maximum_percent = 200
  deployment_minimum_healthy_percent = 100
  enable_ecs_managed_tags = false
  health_check_grace_period_seconds = 60
  launch_type = "FARGATE"
  depends_on      = [aws_lb_target_group.terramino, aws_lb_listener.terramino]


  load_balancer {
    target_group_arn = aws_lb_target_group.terramino.arn
    container_name   = "PM-DynamoDB"
    container_port   = 80
  }

  network_configuration {
    security_groups = [aws_security_group.sg.id]
    subnets = [
        aws_subnet.PM-VPC_private_subnet1.id,
        aws_subnet.PM-VPC_private_subnet2.id
    ]
  }
}

resource "aws_ecs_task_definition" "ecs_taskdef" {
  family = "PM-DynamoDB"
  container_definitions = jsonencode([
    {
      name      = "PM-DynamoDB"
      image     = "${aws_ecr_repository.ECR.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
  cpu       = 512
  memory    = 1024
  execution_role_arn = aws_iam_role.ecs_task_exec_role.arn
  task_role_arn = aws_iam_role.ecs_task_exec_role.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
}


// ecs 태스크 실행 역할

resource "aws_iam_role" "ecs_task_exec_role" {
  name = "test-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "ecs-tasks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}


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


resource "aws_iam_role_policy_attachment" "ecs-task" {
  role       = aws_iam_role.ecs_task_exec_role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_role_policy_attachment" "ecs-task1" {
  role       = aws_iam_role.ecs_task_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs-task2" {
  role       = aws_iam_role.ecs_task_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_role_policy_attachment" "ecs-task3" {
  role       = aws_iam_role.ecs_task_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}