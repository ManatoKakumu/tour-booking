data "aws_caller_identity" "current" {}

locals {
  ecs_service_arns = merge(
    data.terraform_remote_state.compute_b.outputs.ecs_service_arns,
    data.terraform_remote_state.compute_c.outputs.ecs_service_arns
  )
  ecr_repository_arns = merge(
    data.terraform_remote_state.compute_b.outputs.ecr_repository_arns,
    data.terraform_remote_state.compute_c.outputs.ecr_repository_arns
  )
}

resource "aws_iam_role" "ecr_tagging_lambda" {
  for_each = local.ecs_service_arns

  name = "ecr-tagging-lambda-${each.key}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
        Action    = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:SourceArn" = "arn:aws:lambda:${var.default_region}:${data.aws_caller_identity.current.account_id}:function:ecr-tagging-lambda-${each.key}"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "basic_execution" {
  for_each = local.ecs_service_arns

  role       = aws_iam_role.ecr_tagging_lambda[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "ecs_ecr_access" {
  for_each = local.ecs_service_arns

  name = "ecs-ecr-access"
  role = aws_iam_role.ecr_tagging_lambda[each.key].id

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
        Resource = each.value
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:PutImage",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:BatchDeleteImage"
        ]
        Resource = local.ecr_repository_arns[each.key]
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:DescribeTaskDefinition"
        ]
        Resource = "arn:aws:ecs:${var.default_region}:${data.aws_caller_identity.current.account_id}:task-definition/${each.key}:*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "sns_publish" {
  for_each = local.ecs_service_arns

  name = "sns-publish"
  role = aws_iam_role.ecr_tagging_lambda[each.key].id

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
