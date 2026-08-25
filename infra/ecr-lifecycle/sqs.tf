resource "aws_sqs_queue" "ecr_tagging_failure" {
  name = "ecr-tagging-failure"
}

resource "aws_sqs_queue_policy" "ecr_tagging_failure" {
  queue_url = aws_sqs_queue.ecr_tagging_failure.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "sns.amazonaws.com" }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.ecr_tagging_failure.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.ecr_tagging_failure.arn
          }
        }
      }
    ]
  })
}
