resource "aws_db_subnet_group" "main" {
  name       = "tour-booking-db-subnet"
  subnet_ids = data.terraform_remote_state.network_sg_alb.outputs.db_subnet_ids
}

resource "aws_db_instance" "main" {
  identifier             = "tour-booking-rds"
  engine                 = "mysql"
  engine_version         = "8.0.46"
  instance_class         = "db.t4g.micro"
  allocated_storage      = 20
  storage_type           = "gp3"
  multi_az               = true
  storage_encrypted      = true
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [data.terraform_remote_state.network_sg_alb.outputs.rds_security_group_id]
  # 誤削除を防ぐためにtrueにすべきだが、個人開発でコストを抑えたいので、terraform destroyしたら削除されるよう、falseとしている
  deletion_protection = false

  backup_retention_period = 7
  backup_window           = "18:30-19:00"
  maintenance_window      = "mon:17:30-mon:18:00"
  skip_final_snapshot     = true

  username                    = "admin"
  manage_master_user_password = true
}
