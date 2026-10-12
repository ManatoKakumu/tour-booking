resource "aws_ecr_repository" "front_b" {
  name                 = "front-b"
  image_tag_mutability = "IMMUTABLE"
  # 検証のたびに作り直す運用のため、イメージが残っていてもdestroyできるようにする
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "api_b" {
  name                 = "api-b"
  image_tag_mutability = "IMMUTABLE"
  # 検証のたびに作り直す運用のため、イメージが残っていてもdestroyできるようにする
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "front_b" {
  repository = aws_ecr_repository.front_b.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "「success」タグの画像は直近5件のみ残す"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["success"]
          # sinceImagePushedはタグを付けた日ではなくプッシュ日から数えるため、長くcurrentだった
          # イメージがsuccessに変わった直後に消えてしまう。ロールバック先を残すため件数で保持する
          countType   = "imageCountMoreThan"
          countNumber = 5
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

resource "aws_ecr_lifecycle_policy" "api_b" {
  repository = aws_ecr_repository.api_b.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "「success」タグの画像は直近5件のみ残す"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["success"]
          # sinceImagePushedはタグを付けた日ではなくプッシュ日から数えるため、長くcurrentだった
          # イメージがsuccessに変わった直後に消えてしまう。ロールバック先を残すため件数で保持する
          countType   = "imageCountMoreThan"
          countNumber = 5
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

