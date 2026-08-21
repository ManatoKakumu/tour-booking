output "app_secret_arns" {
  value = { for k, v in aws_secretsmanager_secret.app : k => v.arn }
}
