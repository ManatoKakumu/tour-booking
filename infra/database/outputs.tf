output "app_secret_arns" {
  value = { for k, v in aws_secretsmanager_secret.app : k => v.arn }
}

output "master_user_secret_arn" {
  value = aws_db_instance.main.master_user_secret[0].secret_arn
}

output "db_endpoint" {
  value = aws_db_instance.main.address
}
