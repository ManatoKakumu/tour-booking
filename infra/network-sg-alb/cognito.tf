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

  user_pool_tier = "PLUS"

  user_pool_add_ons {
    advanced_security_mode = "ENFORCED"
  }

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

resource "aws_secretsmanager_secret" "cognito_client_secret_b" {
  name = "cognito-client-secret-b"
}

resource "aws_secretsmanager_secret_version" "cognito_client_secret_b" {
  secret_id     = aws_secretsmanager_secret.cognito_client_secret_b.id
  secret_string = aws_cognito_user_pool_client.b.client_secret
}

resource "aws_secretsmanager_secret" "cognito_client_secret_c" {
  name = "cognito-client-secret-c"
}

resource "aws_secretsmanager_secret_version" "cognito_client_secret_c" {
  secret_id     = aws_secretsmanager_secret.cognito_client_secret_c.id
  secret_string = aws_cognito_user_pool_client.c.client_secret
}

resource "aws_cognito_risk_configuration" "c" {
  user_pool_id = aws_cognito_user_pool.c.id

  compromised_credentials_risk_configuration {
    actions {
      event_action = "BLOCK"
    }
  }
}
