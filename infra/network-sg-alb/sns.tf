resource "aws_sns_topic" "cognito_alert" {
  name = "cognito-alert"
}

variable "notification_email" {
  type      = string
  sensitive = true
}

resource "aws_sns_topic_subscription" "cognito_alert_email" {
  topic_arn = aws_sns_topic.cognito_alert.arn
  protocol  = "email"
  endpoint  = var.notification_email
}
