data "aws_caller_identity" "current" {}

resource "aws_iam_role" "stripe_ip_lambda" {
  name = "stripe-ip-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
        Action    = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:SourceArn" = "arn:aws:lambda:ap-northeast-1:${data.aws_caller_identity.current.account_id}:function:stripe-ip"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.stripe_ip_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "modify_managed_prefix_list" {
  name = "modify-managed-prefix-list"
  role = aws_iam_role.stripe_ip_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:ModifyManagedPrefixList",
          "ec2:GetManagedPrefixListEntries"
        ]
        Resource = data.terraform_remote_state.network_sg_alb.outputs.managed_prefix_for_stripe_arn
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeManagedPrefixLists"
        ]
        Resource = "*"
      }
    ]
  })
}
