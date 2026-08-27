data "aws_caller_identity" "current" {}

resource "aws_iam_role" "ecr_tagging_lambda" {
  name = "ecr-tagging-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
        Action    = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:SourceArn" = "arn:aws:lambda:ap-northeast-1:${data.aws_caller_identity.current.account_id}:function:ecr-tagging"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.ecr_tagging_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "ecs_ecr_access" {
  name = "ecs-ecr-access"
  role = aws_iam_role.ecr_tagging_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:ListServiceDeployments",
          "ecs:DescribeServiceDeployments",
          "ecs:DescribeServiceRevisions",
          "ecs:DescribeServices"
        ]
        Resource = concat(
          values(data.terraform_remote_state.compute_b.outputs.ecs_service_arns),
          values(data.terraform_remote_state.compute_c.outputs.ecs_service_arns)
        )
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:PutImage",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:BatchDeleteImage"
        ]
        Resource = concat(
          values(data.terraform_remote_state.compute_b.outputs.ecr_repository_arns),
          values(data.terraform_remote_state.compute_c.outputs.ecr_repository_arns)
        )
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:DescribeTaskDefinition"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "sns_publish" {
  name = "sns-publish"
  role = aws_iam_role.ecr_tagging_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = aws_sns_topic.ecr_tagging_failure.arn
      }
    ]
  })
}
