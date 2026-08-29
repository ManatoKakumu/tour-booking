resource "aws_lb" "main" {
  name               = "tour-booking-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [for s in aws_subnet.alb : s.id]

  tags = {
    Name = "tour-booking-alb"
  }
}

resource "aws_lb_target_group" "front_b" {
  name        = "tg-front-b"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 5
  }

  tags = {
    Name = "tg-front-b"
  }
}

resource "aws_lb_target_group" "front_c" {
  name        = "tg-front-c"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 5
  }

  tags = {
    Name = "tg-front-c"
  }
}

resource "aws_lb_target_group" "api_b" {
  name        = "tg-api-b"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/b/api/health/"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 5
  }

  tags = {
    Name = "tg-api-b"
  }
}

resource "aws_lb_target_group" "api_c" {
  name        = "tg-api-c"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/api/health/"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 5
  }

  tags = {
    Name = "tg-api-c"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = data.terraform_remote_state.route53_acm.outputs.alb_certificate_arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_c.arn
  }
}

resource "aws_lb_listener_rule" "b_api" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  condition {
    path_pattern {
      values = ["/b/api/*"]
    }
  }

  action {
    type  = "authenticate-cognito"
    order = 1

    authenticate_cognito {
      user_pool_arn       = aws_cognito_user_pool.b.arn
      user_pool_client_id = aws_cognito_user_pool_client.b.id
      user_pool_domain    = aws_cognito_user_pool_domain.b.domain
    }
  }

  action {
    type             = "forward"
    order            = 2
    target_group_arn = aws_lb_target_group.api_b.arn
  }
}

resource "aws_lb_listener_rule" "b_front" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  condition {
    path_pattern {
      values = ["/b/*"]
    }
  }

  action {
    type  = "authenticate-cognito"
    order = 1

    authenticate_cognito {
      user_pool_arn       = aws_cognito_user_pool.b.arn
      user_pool_client_id = aws_cognito_user_pool_client.b.id
      user_pool_domain    = aws_cognito_user_pool_domain.b.domain
    }
  }

  action {
    type             = "forward"
    order            = 2
    target_group_arn = aws_lb_target_group.front_b.arn
  }
}

resource "aws_lb_listener_rule" "c_api" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 30

  condition {
    path_pattern {
      values = ["/c/mypage/api/*", "/c/booking/api/*"]
    }
  }

  action {
    type  = "authenticate-cognito"
    order = 1

    authenticate_cognito {
      user_pool_arn       = aws_cognito_user_pool.c.arn
      user_pool_client_id = aws_cognito_user_pool_client.c.id
      user_pool_domain    = aws_cognito_user_pool_domain.c.domain
    }
  }

  action {
    type             = "forward"
    order            = 2
    target_group_arn = aws_lb_target_group.api_c.arn
  }
}

resource "aws_lb_listener_rule" "c_front" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 40

  condition {
    path_pattern {
      values = ["/c/mypage/*", "/c/booking/*"]
    }
  }

  action {
    type  = "authenticate-cognito"
    order = 1

    authenticate_cognito {
      user_pool_arn       = aws_cognito_user_pool.c.arn
      user_pool_client_id = aws_cognito_user_pool_client.c.id
      user_pool_domain    = aws_cognito_user_pool_domain.c.domain
    }
  }

  action {
    type             = "forward"
    order            = 2
    target_group_arn = aws_lb_target_group.front_c.arn
  }
}

resource "aws_lb_listener_rule" "c_api_without_login" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 50

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }

  action {
    type             = "forward"
    order            = 1
    target_group_arn = aws_lb_target_group.api_c.arn
  }
}
