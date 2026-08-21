resource "aws_cloudwatch_log_group" "front_c" {
  name              = "/ecs/front-c"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "api_c" {
  name              = "/ecs/api-c"
  retention_in_days = 30
}
