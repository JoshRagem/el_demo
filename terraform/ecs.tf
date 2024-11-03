
resource "aws_cloudwatch_log_group" "el_demo" {
  name = "/ecs/el-demo"
}

resource "aws_ecs_cluster" "el_demo" {
  name = "el-demo"
}

locals {
  container_name = "api"
}

resource "aws_security_group" "api" {
  name_prefix = "el_demo_api."
  description = "Security group for api"
  vpc_id      = aws_vpc.el_demo.id

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_iam_policy_document" "assume_ecs" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name               = "el-demo-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.assume_ecs.json
}
resource "aws_iam_role" "ecs_task_app" {
  name               = "el-demo-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_ecs.json
}
resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.ecs_task_execution.arn
}
resource "aws_iam_role_policy_attachment" "ecs_task_app" {
  role       = aws_iam_role.ecs_task_app.name
  policy_arn = aws_iam_policy.ecs_task_app.arn
}

resource "aws_iam_policy" "ecs_task_execution" {
    name = "el-demo-task-execution"
    policy = data.aws_iam_policy_document.ecs_task_execution.json
}
data "aws_iam_policy_document" "ecs_task_execution" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      aws_secretsmanager_secret.el_secret_key_base.arn,
      aws_secretsmanager_secret.el_db_url.arn
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "ecs_task_app" {
    name = "el-demo-task"
    policy = data.aws_iam_policy_document.ecs_task_app.json
}
data "aws_iam_policy_document" "ecs_task_app" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_ecs_task_definition" "api" {
  family                   = "el-demo-template"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048

  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  task_role_arn      = aws_iam_role.ecs_task_app.arn

  container_definitions = jsonencode([
    {
      essential = true
      image     = var.api_image
      name      = local.container_name

      portMappings = [
        {
          containerPort = 4000
          hostPort      = 4000
          protocol      = "tcp"
        },
      ]

      secrets = [
        {
          name      = "SECRET_KEY_BASE"
          valueFrom = aws_secretsmanager_secret_version.el_secret_key_base.arn
        },
        {
          name      = "DATABASE_URL"
          valueFrom = aws_secretsmanager_secret_version.el_db_url.arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.el_demo.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "stdout"
        }
      }
    }
  ])
}
resource "aws_ecs_service" "api" {
  name            = "el-demo-api"
  cluster         = aws_ecs_cluster.el_demo.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  deployment_controller {
    type = "ECS"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.el_demo_api.arn
    container_name   = local.container_name
    container_port   = 4000
  }

  network_configuration {
    security_groups  = [aws_security_group.api.id]
    subnets          = aws_subnet.public.*.id
    assign_public_ip = false
  }

  force_new_deployment = true

  triggers = {
    redeployment = plantimestamp()
  }

  lifecycle {
    ignore_changes = [
      task_definition
    ]
  }
}
