output "db_subnet_ids" {
  value = [for s in aws_subnet.db : s.id]
}

output "rds_security_group_id" {
  value = aws_security_group.rds.id
}

output "iam_openid_connect_provider" {
  value = aws_iam_openid_connect_provider.github_actions.arn
}
