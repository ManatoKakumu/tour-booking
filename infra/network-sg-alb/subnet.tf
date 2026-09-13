locals {
  alb_subnets = {
    "${var.default_region}a" = "10.0.0.0/24"
    "${var.default_region}c" = "10.0.10.0/24"
  }
}

resource "aws_subnet" "alb" {
  for_each          = local.alb_subnets
  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name = "alb-${each.key}"
  }
}

locals {
  ecs_front_subnets = {
    "${var.default_region}a" = "10.0.1.0/24"
    "${var.default_region}c" = "10.0.11.0/24"
  }
}

resource "aws_subnet" "ecs_front" {
  for_each          = local.ecs_front_subnets
  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name = "ecs-front-${each.key}"
  }
}

locals {
  ecs_api_subnets = {
    "${var.default_region}a" = "10.0.2.0/24"
    "${var.default_region}c" = "10.0.12.0/24"
  }
}

resource "aws_subnet" "ecs_api" {
  for_each          = local.ecs_api_subnets
  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name = "ecs-api-${each.key}"
  }
}

locals {
  db_subnets = {
    "${var.default_region}a" = "10.0.3.0/24"
    "${var.default_region}c" = "10.0.13.0/24"
  }
}

resource "aws_subnet" "db" {
  for_each          = local.db_subnets
  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name = "db-${each.key}"
  }
}
