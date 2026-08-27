resource "aws_security_group" "alb" {
  name        = "alb-sg"
  description = "Allows inbound from CloudFront, outbound to ECS front/API"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "alb-sg"
  }
}

resource "aws_security_group" "ecs_front" {
  name        = "ecs-front-sg"
  description = "Allows inbound from ALB, outbound to VPC endpoints"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "ecs-front-sg"
  }
}

resource "aws_security_group" "ecs_api" {
  name        = "ecs-api-sg"
  description = "Allows inbound from ALB, outbound to RDS, VPC endpoints, S3, and NAT Gateway for external API calls"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "ecs-api-sg"
  }
}

resource "aws_security_group" "rds" {
  name        = "rds-sg"
  description = "Allows inbound from ECS API, outbound for replication sync"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "rds-sg"
  }
}

resource "aws_security_group" "vpc_endpoint" {
  name        = "vpc-endpoint-sg"
  description = "Allows inbound from ECS front/API"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "vpc-endpoint-sg"
  }
}

# ALB ← CloudFrontのSGはCloudFront作成後に記載

# ALB → ECS front (ALB側のOutbound)
resource "aws_vpc_security_group_egress_rule" "alb_to_ecs_front" {
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.ecs_front.id
  from_port                    = 3000
  to_port                      = 3000
  ip_protocol                  = "tcp"
  description                  = "To ECS front"
}

# ALB → ECS api (ALB側のOutbound)
resource "aws_vpc_security_group_egress_rule" "alb_to_ecs_api" {
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.ecs_api.id
  from_port                    = 3000
  to_port                      = 3000
  ip_protocol                  = "tcp"
  description                  = "To ECS api"
}

# ECS front ← ALB（ECS front側のInbound）
resource "aws_vpc_security_group_ingress_rule" "ecs_front_from_alb" {
  security_group_id            = aws_security_group.ecs_front.id
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 3000
  to_port                      = 3000
  ip_protocol                  = "tcp"
  description                  = "From ALB"
}

# ECS front → VPCエンドポイント (ECS front側のOutbound)
resource "aws_vpc_security_group_egress_rule" "ecs_front_to_vpc_endpoint" {
  security_group_id            = aws_security_group.ecs_front.id
  referenced_security_group_id = aws_security_group.vpc_endpoint.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  description                  = "To VPC Endpoint"
}

# ECS front → S3エンドポイント (ECS front側のOutbound)
resource "aws_vpc_security_group_egress_rule" "ecs_front_to_s3" {
  security_group_id = aws_security_group.ecs_front.id
  prefix_list_id    = data.aws_prefix_list.s3.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "To S3 (ECR image layers) via Gateway endpoint"
}

# ECS api ← ALB（ECS api側のInbound）
resource "aws_vpc_security_group_ingress_rule" "ecs_api_from_alb" {
  security_group_id            = aws_security_group.ecs_api.id
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 3000
  to_port                      = 3000
  ip_protocol                  = "tcp"
  description                  = "From ALB"
}

# ECS api → RDS (ECS api側のOutbound)
resource "aws_vpc_security_group_egress_rule" "ecs_api_to_rds" {
  security_group_id            = aws_security_group.ecs_api.id
  referenced_security_group_id = aws_security_group.rds.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
  description                  = "To RDS"
}

# ECS api → VPCエンドポイント (ECS api側のOutbound)
resource "aws_vpc_security_group_egress_rule" "ecs_api_to_vpc_endpoint" {
  security_group_id            = aws_security_group.ecs_api.id
  referenced_security_group_id = aws_security_group.vpc_endpoint.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  description                  = "To VPC Endpoint"
}

# ECS api → S3 Gateway (ECS api側のOutbound)
data "aws_prefix_list" "s3" {
  name = "com.amazonaws.ap-northeast-1.s3"
}

resource "aws_vpc_security_group_egress_rule" "ecs_api_to_s3" {
  security_group_id = aws_security_group.ecs_api.id
  prefix_list_id    = data.aws_prefix_list.s3.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "To S3 (image bucket) via Gateway endpoint"
}

# ECS api → Stripe (ECS api側のOutbound)
resource "aws_ec2_managed_prefix_list" "stripe" {
  name           = "stripe-api-ips"
  address_family = "IPv4"
  max_entries    = 150
}

resource "aws_vpc_security_group_egress_rule" "ecs_api_to_stripe" {
  security_group_id = aws_security_group.ecs_api.id
  prefix_list_id    = aws_ec2_managed_prefix_list.stripe.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "To Stripe"
}

# RDS ← ECS api（RDS側のInbound）
resource "aws_vpc_security_group_ingress_rule" "rds_from_ecs_api" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = aws_security_group.ecs_api.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
  description                  = "From ECS api"
}

# VPCエンドポイント ← ECS front（VPCエンドポイント側のInbound）
resource "aws_vpc_security_group_ingress_rule" "vpc_endpoint_from_ecs_front" {
  security_group_id            = aws_security_group.vpc_endpoint.id
  referenced_security_group_id = aws_security_group.ecs_front.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  description                  = "From ECS front"
}

# VPCエンドポイント ← ECS api（VPCエンドポイント側のInbound）
resource "aws_vpc_security_group_ingress_rule" "vpc_endpoint_from_ecs_api" {
  security_group_id            = aws_security_group.vpc_endpoint.id
  referenced_security_group_id = aws_security_group.ecs_api.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  description                  = "From ECS api"
}
