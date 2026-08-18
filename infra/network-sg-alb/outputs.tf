output "db_subnet_ids" {
  value = [for s in aws_subnet.db : s.id]
}

output "rds_security_group_id" {
  value = aws_security_group.rds.id
}
