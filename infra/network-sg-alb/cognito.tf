resource "aws_cognito_user_pool" "b" {
  name = "tour-booking-b"

  mfa_configuration = "ON"

  software_token_mfa_configuration {
    enabled = true
  }

  tags = {
    Name = "tour-booking-user-pool-b"
  }
}

resource "aws_cognito_user_pool" "c" {
  name = "tour-booking-c"

  tags = {
    Name = "tour-booking-user-pool-c"
  }
}

resource "aws_cognito_user_pool_client" "b" {
  name         = "tour-booking-b-client"
  user_pool_id = aws_cognito_user_pool.b.id

  generate_secret = true

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid"]

  callback_urls = ["https://sample-sample.jp/oauth2/idpresponse"]
}

resource "aws_cognito_user_pool_client" "c" {
  name         = "tour-booking-c-client"
  user_pool_id = aws_cognito_user_pool.c.id

  generate_secret = true

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid"]

  callback_urls = ["https://sample-sample.jp/oauth2/idpresponse"]
}

resource "aws_cognito_user_pool_domain" "b" {
  domain       = "tour-booking-b"
  user_pool_id = aws_cognito_user_pool.b.id
}

resource "aws_cognito_user_pool_domain" "c" {
  domain       = "tour-booking-c"
  user_pool_id = aws_cognito_user_pool.c.id
}
