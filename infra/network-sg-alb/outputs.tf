output "db_subnet_ids" {
  value = [for s in aws_subnet.db : s.id]
}

output "rds_security_group_id" {
  value = aws_security_group.rds.id
}

output "iam_openid_connect_provider" {
  value = aws_iam_openid_connect_provider.github_actions.arn
}

output "ecs_front_subnet_ids" {
  value = [for s in aws_subnet.ecs_front : s.id]
}

output "ecs_api_subnet_ids" {
  value = [for s in aws_subnet.ecs_api : s.id]
}

output "ecs_front_security_group_id" {
  value = aws_security_group.ecs_front.id
}

output "ecs_api_security_group_id" {
  value = aws_security_group.ecs_api.id
}

output "target_group_arns" {
  value = {
    front-b = aws_lb_target_group.front_b.arn
    front-c = aws_lb_target_group.front_c.arn
    api-b   = aws_lb_target_group.api_b.arn
    api-c   = aws_lb_target_group.api_c.arn
  }
}

output "alb_arn_suffix" {
  value = aws_lb.main.arn_suffix
}

output "target_group_arn_suffixes" {
  value = {
    front-b = aws_lb_target_group.front_b.arn_suffix
    front-c = aws_lb_target_group.front_c.arn_suffix
    api-b   = aws_lb_target_group.api_b.arn_suffix
    api-c   = aws_lb_target_group.api_c.arn_suffix
  }
}
