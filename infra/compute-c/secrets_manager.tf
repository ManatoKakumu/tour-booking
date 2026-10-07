variable "stripe_secret_key" {
  type      = string
  sensitive = true
  ephemeral = true
}

resource "aws_secretsmanager_secret" "stripe_secret_key" {
  name                    = "stripe_secret_key"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "stripe_secret_key" {
  secret_id                = aws_secretsmanager_secret.stripe_secret_key.id
  secret_string_wo         = var.stripe_secret_key
  secret_string_wo_version = 1
}
