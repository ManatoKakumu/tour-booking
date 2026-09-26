resource "aws_cloudwatch_event_rule" "ecs_deployment" {
  for_each = local.ecs_service_arns

  name = "ecs-deployment-${each.key}"

  event_pattern = jsonencode({
    source      = ["aws.ecs"]
    detail-type = ["ECS Deployment State Change"]
    resources   = [each.value]
    detail = {
      eventName = ["SERVICE_DEPLOYMENT_COMPLETED", "SERVICE_DEPLOYMENT_FAILED"]
    }
  })
}

resource "aws_cloudwatch_event_target" "ecr_tagging" {
  for_each = local.ecs_service_arns

  rule = aws_cloudwatch_event_rule.ecs_deployment[each.key].name
  arn  = aws_lambda_function.ecr_tagging[each.key].arn
}

resource "aws_lambda_permission" "eventbridge" {
  for_each = local.ecs_service_arns

  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ecr_tagging[each.key].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ecs_deployment[each.key].arn
}
