locals {
  db_users = toset(["b_front", "b_api", "c_front", "c_api"])
}

resource "random_password" "app" {
  for_each         = local.db_users
  length           = 20
  special          = true
  override_special = "!#%&*-_="
}

resource "aws_secretsmanager_secret" "app" {
  for_each                = local.db_users
  name                    = "tour-booking-rds-${each.key}"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "app" {
  for_each      = local.db_users
  secret_id     = aws_secretsmanager_secret.app[each.key].id
  secret_string = random_password.app[each.key].result
}
