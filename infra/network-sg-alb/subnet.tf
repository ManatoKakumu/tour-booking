variable "alb_subnets" {
  type = map(string)
  default = {
    "ap-northeast-1a" = "10.0.0.0/24"
    "ap-northeast-1c" = "10.0.10.0/24"
  }
}

resource "aws_subnet" "alb" {
  for_each          = var.alb_subnets
  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name = "alb-${each.key}"
  }
}

variable "ecs_front_subnets" {
  type = map(string)
  default = {
    "ap-northeast-1a" = "10.0.1.0/24"
    "ap-northeast-1c" = "10.0.11.0/24"
  }
}

resource "aws_subnet" "ecs_front" {
  for_each          = var.ecs_front_subnets
  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name = "ecs-front-${each.key}"
  }
}

variable "ecs_api_subnets" {
  type = map(string)
  default = {
    "ap-northeast-1a" = "10.0.2.0/24"
    "ap-northeast-1c" = "10.0.12.0/24"
  }
}

resource "aws_subnet" "ecs_api" {
  for_each          = var.ecs_api_subnets
  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name = "ecs-api-${each.key}"
  }
}

variable "db_subnets" {
  type = map(string)
  default = {
    "ap-northeast-1a" = "10.0.3.0/24"
    "ap-northeast-1c" = "10.0.13.0/24"
  }
}

resource "aws_subnet" "db" {
  for_each          = var.db_subnets
  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name = "db-${each.key}"
  }
}
