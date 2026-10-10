# DB用ルートテーブル(localのみ)
resource "aws_route_table" "shared" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "rtb-shared"
  }
}

# ALB用ルートテーブル
# authenticate-cognitoでは、ALB自身がCognitoのトークンエンドポイント・ユーザー情報エンドポイントへ
# HTTPSで接続するため、内部向けALBでもNAT Gateway経由の外向き経路が必要
resource "aws_route_table" "alb" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "rtb-alb"
  }
}

resource "aws_route_table" "front" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "rtb-front"
  }
}

# API用ルートテーブル
resource "aws_route_table" "api" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "rtb-api"
  }
}

resource "aws_route_table_association" "alb" {
  for_each       = aws_subnet.alb
  subnet_id      = each.value.id
  route_table_id = aws_route_table.alb.id
}

resource "aws_route_table_association" "front" {
  for_each       = aws_subnet.ecs_front
  subnet_id      = each.value.id
  route_table_id = aws_route_table.front.id
}

resource "aws_route_table_association" "db" {
  for_each       = aws_subnet.db
  subnet_id      = each.value.id
  route_table_id = aws_route_table.shared.id
}

resource "aws_route_table_association" "api" {
  for_each       = aws_subnet.ecs_api
  subnet_id      = each.value.id
  route_table_id = aws_route_table.api.id
}
