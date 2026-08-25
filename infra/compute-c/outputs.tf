output "ecs_service_arns" {
  value = {
    front-c = aws_ecs_service.this["front-c"].id
    api-c   = aws_ecs_service.this["api-c"].id
  }
}

output "ecr_repository_arns" {
  value = {
    front-c = aws_ecr_repository.front_c.arn
    api-c   = aws_ecr_repository.api_c.arn
  }
}
