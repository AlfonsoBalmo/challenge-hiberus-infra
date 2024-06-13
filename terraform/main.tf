provider "aws" {
  region = var.aws_region
}

# Verificar si la VPC ya existe
data "aws_vpcs" "all" {}

resource "aws_vpc" "main" {
  count = length(data.aws_vpcs.all.ids) < 5 ? 1 : 0
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main" {
  count = 2
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)
  cidr_block = cidrsubnet(aws_vpc.main[0].cidr_block, 8, count.index)
  vpc_id = aws_vpc.main[0].id
}

resource "aws_security_group" "ecs_sg" {
  name_prefix = "ecs_sg_"
  vpc_id = aws_vpc.main[0].id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "main-subnet-group"
  subnet_ids = aws_subnet.main[*].id
}

resource "aws_db_instance" "default" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  db_name                = var.db_name
  username               = var.db_user
  password               = var.db_password
  parameter_group_name   = "default.mysql5.7"
  vpc_security_group_ids = [aws_security_group.ecs_sg.id]
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.main.name
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

resource "aws_iam_role" "ecs_task_execution_role" {
  count = length(data.aws_iam_role.ecs_task_execution_role) == 0 ? 1 : 0

  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  count = length(data.aws_iam_role.ecs_task_execution_role) == 0 ? 1 : 0

  role       = coalesce(aws_iam_role.ecs_task_execution_role[0].name, data.aws_iam_role.ecs_task_execution_role.name)
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_cluster" "main" {
  name = "ecs-cluster"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "my-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = coalesce(data.aws_iam_role.ecs_task_execution_role.arn, aws_iam_role.ecs_task_execution_role[0].arn)

  container_definitions = jsonencode([
    {
      name      = "my-app"
      image     = "${aws_ecr_repository.myapp.repository_url}:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ],
      environment = [
        { name = "MYSQLDB_HOST", value = aws_db_instance.default.endpoint },
        { name = "MYSQLDB_USER", value = var.db_user },
        { name = "MYSQLDB_PASSWORD", value = var.db_password },
        { name = "MYSQLDB_NAME", value = var.db_name },
        { name = "MYSQLDB_PORT", value = "3306" }
      ]
    }
  ])
}

resource "aws_ecs_service" "app" {
  name            = "my-app-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = aws_subnet.main[*].id
    security_groups = [aws_security_group.ecs_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "my-app"
    container_port   = 80
  }
}

resource "aws_lb" "app" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_sg.id]
  subnets            = aws_subnet.main[*].id
}

resource "aws_lb_target_group" "app" {
  name     = "app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main[0].id
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-299"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

data "aws_ecr_repository" "myapp" {
  name = "myapp"
}

resource "aws_ecr_repository" "myapp" {
  count = length(data.aws_ecr_repository.myapp) == 0 ? 1 : 0

  name = "myapp"
}
