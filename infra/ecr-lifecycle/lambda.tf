data "archive_file" "ecr_tagging" {
  type        = "zip"
  source_file = "${path.module}/lambda/handler.py"
  output_path = "${path.module}/lambda/handler.zip"
}

resource "aws_lambda_function" "ecr_tagging" {
  function_name    = "ecr-tagging"
  role             = aws_iam_role.ecr_tagging_lambda.arn
  handler          = "handler.handler"
  runtime          = "python3.12"
  timeout          = 60
  filename         = data.archive_file.ecr_tagging.output_path
  source_code_hash = data.archive_file.ecr_tagging.output_base64sha256

  reserved_concurrent_executions = 4
}

resource "aws_lambda_function_event_invoke_config" "ecr_tagging" {
  function_name = aws_lambda_function.ecr_tagging.function_name

  destination_config {
    on_failure {
      destination = aws_sns_topic.ecr_tagging_failure.arn
    }
  }
}
