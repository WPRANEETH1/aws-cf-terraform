output "rds_endpoint" {
  description = "RDS host endpoint"
  value       = split(":", aws_db_instance.mariadb_master.endpoint)[0]
}

output "rds_username" {
  description = "RDS master username"
  value       = aws_db_instance.mariadb_master.username
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.mariadb_master.db_name
}

output "rds_password" {
  description = "RDS master password"
  value       = aws_db_instance.mariadb_master.password
}

output "mariadb_sg" {
  description = "RDS mariadb security group"
  value       = aws_security_group.mariadb_sg
}
