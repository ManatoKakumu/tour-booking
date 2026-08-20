resource "aws_iam_role" "front_b_ecr_push" {
  name = "front-b-ecr-push"

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
            "token.actions.githubusercontent.com:sub" = "repo:ManatoKakumu@*/tour-booking@*:environment:front-b"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "front_b_ecr_push" {
  name = "front-b-ecr-push-policy"
  role = aws_iam_role.front_b_ecr_push.id

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
        Resource = aws_ecr_repository.front_b.arn
      }
    ]
  })
}

resource "aws_iam_role" "api_b_ecr_push" {
  name = "api-b-ecr-push"

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
            "token.actions.githubusercontent.com:sub" = "repo:ManatoKakumu@*/tour-booking@*:environment:api-b"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "api_b_ecr_push" {
  name = "api-b-ecr-push-policy"
  role = aws_iam_role.api_b_ecr_push.id

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
        Resource = aws_ecr_repository.api_b.arn
      }
    ]
  })
}
