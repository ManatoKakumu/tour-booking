resource "aws_cloudwatch_log_group" "cognito_auth_events_b" {
  name = "/cognito/auth-events-b"
}

resource "aws_cloudwatch_log_group" "cognito_auth_events_c" {
  name = "/cognito/auth-events-c"
}

resource "aws_cloudwatch_contributor_insight_rule" "signin_failure_by_user_b" {
  rule_name  = "signin-failure-by-user-b"
  rule_state = "ENABLED"

  rule_definition = jsonencode({
    Schema        = { Name = "CloudWatchLogRule", Version = 1 }
    LogGroupNames = [aws_cloudwatch_log_group.cognito_auth_events_b.name]
    LogFormat     = "JSON"
    Contribution = {
      Keys = ["$.message.userName"]
      Filters = [
        { Match = "$.message.eventType", In = ["SignIn"] },
        { Match = "$.message.eventResponse", In = ["Fail"] }
      ]
    }
    AggregateOn = "Count"
  })
}

resource "aws_cloudwatch_metric_alarm" "signin_failure_by_user_b" {
  alarm_name          = "signin-failure-by-user-b"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 10
  evaluation_periods  = 1
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "max_failure"
    period      = 300
    expression  = "INSIGHT_RULE_METRIC(\"${aws_cloudwatch_contributor_insight_rule.signin_failure_by_user_b.rule_name}\", \"MaxContributorValue\")"
    label       = "Max SignIn Failures by a single user (B)"
    return_data = true
  }

  alarm_actions = [aws_sns_topic.cognito_alert.arn]
}

resource "aws_cloudwatch_contributor_insight_rule" "signin_failure_by_user_c" {
  rule_name  = "signin-failure-by-user-c"
  rule_state = "ENABLED"

  rule_definition = jsonencode({
    Schema        = { Name = "CloudWatchLogRule", Version = 1 }
    LogGroupNames = [aws_cloudwatch_log_group.cognito_auth_events_c.name]
    LogFormat     = "JSON"
    Contribution = {
      Keys = ["$.message.userName"]
      Filters = [
        { Match = "$.message.eventType", In = ["SignIn"] },
        { Match = "$.message.eventResponse", In = ["Fail"] }
      ]
    }
    AggregateOn = "Count"
  })
}

resource "aws_cloudwatch_metric_alarm" "signin_failure_by_user_c" {
  alarm_name          = "signin-failure-by-user-c"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 10
  evaluation_periods  = 1
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "max_failure"
    period      = 300
    expression  = "INSIGHT_RULE_METRIC(\"${aws_cloudwatch_contributor_insight_rule.signin_failure_by_user_c.rule_name}\", \"MaxContributorValue\")"
    label       = "Max SignIn Failures by a single user (C)"
    return_data = true
  }

  alarm_actions = [aws_sns_topic.cognito_alert.arn]
}

resource "aws_cloudwatch_metric_alarm" "signin_failure_rate_b" {
  alarm_name          = "signin-failure-rate-b"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0.9
  evaluation_periods  = 1
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "failure_rate"
    expression  = "IF(total > 10, (total - success) / total, 0)"
    label       = "SignIn Failure Rate (B)"
    return_data = true
  }

  metric_query {
    id = "total"
    metric {
      metric_name = "SignInSuccesses"
      namespace   = "AWS/Cognito"
      period      = 300
      stat        = "SampleCount"
      dimensions = {
        UserPool       = aws_cognito_user_pool.b.id
        UserPoolClient = aws_cognito_user_pool_client.b.id
      }
    }
  }

  metric_query {
    id = "success"
    metric {
      metric_name = "SignInSuccesses"
      namespace   = "AWS/Cognito"
      period      = 300
      stat        = "Sum"
      dimensions = {
        UserPool       = aws_cognito_user_pool.b.id
        UserPoolClient = aws_cognito_user_pool_client.b.id
      }
    }
  }

  alarm_actions = [aws_sns_topic.cognito_alert.arn]
}

resource "aws_cloudwatch_metric_alarm" "signin_failure_rate_c" {
  alarm_name          = "signin-failure-rate-c"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0.9
  evaluation_periods  = 1
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "failure_rate"
    expression  = "IF(total > 10, (total - success) / total, 0)"
    label       = "SignIn Failure Rate (C)"
    return_data = true
  }

  metric_query {
    id = "total"
    metric {
      metric_name = "SignInSuccesses"
      namespace   = "AWS/Cognito"
      period      = 300
      stat        = "SampleCount"
      dimensions = {
        UserPool       = aws_cognito_user_pool.c.id
        UserPoolClient = aws_cognito_user_pool_client.c.id
      }
    }
  }

  metric_query {
    id = "success"
    metric {
      metric_name = "SignInSuccesses"
      namespace   = "AWS/Cognito"
      period      = 300
      stat        = "Sum"
      dimensions = {
        UserPool       = aws_cognito_user_pool.c.id
        UserPoolClient = aws_cognito_user_pool_client.c.id
      }
    }
  }

  alarm_actions = [aws_sns_topic.cognito_alert.arn]
}
