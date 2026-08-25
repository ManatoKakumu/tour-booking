resource "aws_sns_topic" "ecr_tagging_failure" {
  name = "ecr-tagging-failure"
}

resource "aws_sns_topic_subscription" "sqs" {
  topic_arn = aws_sns_topic.ecr_tagging_failure.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.ecr_tagging_failure.arn
}

variable "notification_email" {
  type      = string
  sensitive = true
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.ecr_tagging_failure.arn
  protocol  = "email"
  endpoint  = var.notification_email
}
