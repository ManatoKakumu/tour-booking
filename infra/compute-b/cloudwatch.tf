resource "aws_cloudwatch_log_group" "front_b" {
  name              = "/ecs/front-b"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "api_b" {
  name              = "/ecs/api-b"
  retention_in_days = 30
}
