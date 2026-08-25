resource "aws_ecr_repository" "front_c" {
  name                 = "front-c"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "api_c" {
  name                 = "api-c"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "front_c" {
  repository = aws_ecr_repository.front_c.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "「success」タグの画像を90日で削除"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["success"]
          countType     = "sinceImagePushed"
          countUnit     = "days"
          countNumber   = 90
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "「fail」タグの画像を30日で削除"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["fail"]
          countType     = "sinceImagePushed"
          countUnit     = "days"
          countNumber   = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}


resource "aws_ecr_lifecycle_policy" "api_c" {
  repository = aws_ecr_repository.api_c.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "「success」タグの画像を90日で削除"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["success"]
          countType     = "sinceImagePushed"
          countUnit     = "days"
          countNumber   = 90
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "「fail」タグの画像を30日で削除"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["fail"]
          countType     = "sinceImagePushed"
          countUnit     = "days"
          countNumber   = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
