resource "aws_ecs_cluster" "c" {
  name = "tour-booking-c"
}

variable "front_c_image_tag" {
  type = string
}

variable "api_c_image_tag" {
  type = string
}

locals {
  ecs_services = {
    front-c = {
      execution_role_arn = aws_iam_role.ecs_execution_front_c.arn
      ecr_repository_url = aws_ecr_repository.front_c.repository_url
      log_group_name     = aws_cloudwatch_log_group.front_c.name
      image_tag          = var.front_c_image_tag
      subnet_ids         = data.terraform_remote_state.network_sg_alb.outputs.ecs_front_subnet_ids
      security_group_id  = data.terraform_remote_state.network_sg_alb.outputs.ecs_front_security_group_id
      target_group_arn   = data.terraform_remote_state.network_sg_alb.outputs.target_group_arns["front-c"]
    }
    api-c = {
      execution_role_arn = aws_iam_role.ecs_execution_api_c.arn
      ecr_repository_url = aws_ecr_repository.api_c.repository_url
      log_group_name     = aws_cloudwatch_log_group.api_c.name
      image_tag          = var.api_c_image_tag
      subnet_ids         = data.terraform_remote_state.network_sg_alb.outputs.ecs_api_subnet_ids
      security_group_id  = data.terraform_remote_state.network_sg_alb.outputs.ecs_api_security_group_id
      target_group_arn   = data.terraform_remote_state.network_sg_alb.outputs.target_group_arns["api-c"]
    }
  }
}

resource "aws_ecs_task_definition" "this" {
  for_each                 = local.ecs_services
  family                   = each.key
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = each.value.execution_role_arn

  container_definitions = jsonencode([
    {
      name  = each.key
      image = "${each.value.ecr_repository_url}:${each.value.image_tag}"
      portMappings = [
        { containerPort = 3000, protocol = "tcp" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = each.value.log_group_name
          "awslogs-region"        = "ap-northeast-1"
          "awslogs-stream-prefix" = each.key
        }
      }
    }
  ])

  lifecycle {
    ignore_changes = [container_definitions]
  }
}

resource "aws_ecs_service" "this" {
  for_each        = local.ecs_services
  name            = each.key
  cluster         = aws_ecs_cluster.c.id
  task_definition = aws_ecs_task_definition.this[each.key].arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = each.value.subnet_ids
    security_groups  = [each.value.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = each.value.target_group_arn
    container_name   = each.key
    container_port   = 3000
  }
}

resource "aws_ecs_task_definition" "db_user_setup_c" {
  family                   = "db-user-setup-c"
  requires_compatibilities = ["FARGATE"]
  network_mode              = "awsvpc"
  cpu                       = "256"
  memory                    = "512"
  execution_role_arn        = aws_iam_role.db_user_setup_c.arn

  container_definitions = jsonencode([
    {
      name    = "db-user-setup-c"
      image   = "${aws_ecr_repository.api_c.repository_url}:${var.api_c_image_tag}"
      command = ["python", "create_db_user.py"]

      environment = [
        { name = "DB_HOST", value = data.terraform_remote_state.database.outputs.db_endpoint },
        { name = "APP_DB_USERNAME", value = "c_api" }
      ]

      secrets = [
        {
          name      = "DB_MASTER_USERNAME"
          valueFrom = "${data.terraform_remote_state.database.outputs.master_user_secret_arn}:username::"
        },
        {
          name      = "DB_MASTER_PASSWORD"
          valueFrom = "${data.terraform_remote_state.database.outputs.master_user_secret_arn}:password::"
        },
        {
          name      = "APP_DB_PASSWORD"
          valueFrom = data.terraform_remote_state.database.outputs.app_secret_arns["c_api"]
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.api_c.name
          "awslogs-region"        = "ap-northeast-1"
          "awslogs-stream-prefix" = "db-user-setup-c"
        }
      }
    }
  ])
}
