resource "aws_ecs_cluster" "b" {
  name = "tour-booking-b"
}

variable "front_b_image_tag" {
  type = string
}

variable "api_b_image_tag" {
  type = string
}

locals {
  ecs_services = {
    front-b = {
      execution_role_arn = aws_iam_role.ecs_execution_front_b.arn
      ecr_repository_url = aws_ecr_repository.front_b.repository_url
      log_group_name     = aws_cloudwatch_log_group.front_b.name
      image_tag          = var.front_b_image_tag
      subnet_ids         = data.terraform_remote_state.network_sg_alb.outputs.ecs_front_subnet_ids
      security_group_id  = data.terraform_remote_state.network_sg_alb.outputs.ecs_front_security_group_id
      target_group_arn   = data.terraform_remote_state.network_sg_alb.outputs.target_group_arns["front-b"]
    }
    api-b = {
      execution_role_arn = aws_iam_role.ecs_execution_api_b.arn
      ecr_repository_url = aws_ecr_repository.api_b.repository_url
      log_group_name     = aws_cloudwatch_log_group.api_b.name
      image_tag          = var.api_b_image_tag
      subnet_ids         = data.terraform_remote_state.network_sg_alb.outputs.ecs_api_subnet_ids
      security_group_id  = data.terraform_remote_state.network_sg_alb.outputs.ecs_api_security_group_id
      target_group_arn   = data.terraform_remote_state.network_sg_alb.outputs.target_group_arns["api-b"]
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
  cluster         = aws_ecs_cluster.b.id
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
