data "archive_file" "stripe_ip" {
  type        = "zip"
  source_file = "${path.module}/lambda/handler.py"
  output_path = "${path.module}/lambda/handler.zip"
}

resource "aws_lambda_function" "stripe_ip" {
  function_name    = "stripe-ip"
  role             = aws_iam_role.stripe_ip_lambda.arn
  handler          = "handler.handler"
  runtime          = "python3.12"
  filename         = data.archive_file.stripe_ip.output_path
  source_code_hash = data.archive_file.stripe_ip.output_base64sha256

  reserved_concurrent_executions = 1

  environment {
    variables = {
      PREFIX_LIST_ID = data.terraform_remote_state.network_sg_alb.outputs.managed_prefix_for_stripe_id
    }
  }
}
