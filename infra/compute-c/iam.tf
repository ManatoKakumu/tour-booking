resource "aws_iam_role" "front_c_ecr_push" {
  name = "front-c-ecr-push"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Federated = data.terraform_remote_state.network_sg_alb.outputs.iam_openid_connect_provider }
        Action    = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:ManatoKakumu@*/tour-booking@*:environment:front-c"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "front_c_ecr_push" {
  name = "front-c-ecr-push-policy"
  role = aws_iam_role.front_c_ecr_push.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "ecr:GetAuthorizationToken"
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = aws_ecr_repository.front_c.arn
      }
    ]
  })
}

resource "aws_iam_role" "api_c_ecr_push" {
  name = "api-c-ecr-push"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Federated = data.terraform_remote_state.network_sg_alb.outputs.iam_openid_connect_provider }
        Action    = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:ManatoKakumu@*/tour-booking@*:environment:api-c"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "api_c_ecr_push" {
  name = "api-c-ecr-push-policy"
  role = aws_iam_role.api_c_ecr_push.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "ecr:GetAuthorizationToken"
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = aws_ecr_repository.api_c.arn
      }
    ]
  })
}
