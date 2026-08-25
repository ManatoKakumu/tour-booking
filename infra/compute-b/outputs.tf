output "ecs_service_arns" {
  value = {
    front-b = aws_ecs_service.this["front-b"].id
    api-b   = aws_ecs_service.this["api-b"].id
  }
}

output "ecr_repository_arns" {
  value = {
    front-b = aws_ecr_repository.front_b.arn
    api-b   = aws_ecr_repository.api_b.arn
  }
}
