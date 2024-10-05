resource "aws_db_subnet_group" "mariadb_subnet_group" {

  name       = join("-", [var.vpc_name, var.project, var.environment, "mariadb-subnet-group"])
  subnet_ids = var.private_subnets

  tags = merge(
    {
      Name = join("-", [var.vpc_name, var.project, var.environment, "mariadb-subnet-group"]),
    },
    var.tags
  )
}

resource "aws_security_group" "mariadb_sg" {
  name   = join("-", [var.vpc_name, var.project, var.environment, "mariadb-sg"])
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Conditionally create the ingress rule only if the security_groups_allowed variable is not empty
  dynamic "ingress" {
    for_each = length(var.security_groups_allowed) > 0 ? [1] : []

    content {
      from_port       = 3306
      to_port         = 3306
      protocol        = "TCP"
      security_groups = var.security_groups_allowed
    }
  }

  tags = merge(
    {
      Name = join("-", [var.vpc_name, var.project, var.environment, "mariadb-sg"]),
    },
    var.tags
  )
}

# Create the primary (master) MariaDB instance
resource "aws_db_instance" "mariadb_master" {
  identifier              = join("-", [var.vpc_name, var.project, var.environment, "mariadb-master"])
  allocated_storage       = var.allocated_storage
  engine                  = "mariadb"
  engine_version          = "10.11.8"
  instance_class          = var.instance_class
  username                = var.username
  password                = var.password
  db_subnet_group_name    = aws_db_subnet_group.mariadb_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.mariadb_sg.id]
  skip_final_snapshot     = true
  apply_immediately       = true
  backup_retention_period = 7

  tags = merge(
    {
      Name = join("-", [var.vpc_name, var.project, var.environment, "mariadb-master"]),
    },
    var.tags
  )
}

# Create the read replica (reader)
resource "aws_db_instance" "mariadb_reader" {
  depends_on = [aws_db_instance.mariadb_master]

  identifier             = join("-", [var.vpc_name, var.project, var.environment, "mariadb-reader"])
  engine                 = "mariadb"
  engine_version         = aws_db_instance.mariadb_master.engine_version
  instance_class         = var.instance_class
  replicate_source_db    = aws_db_instance.mariadb_master.identifier
  vpc_security_group_ids = [aws_security_group.mariadb_sg.id]
  skip_final_snapshot    = true
  apply_immediately      = true

  tags = merge(
    {
      Name = join("-", [var.vpc_name, var.project, var.environment, "mariadb-reader"]),
    },
    var.tags
  )
}

resource "aws_ssm_parameter" "db_endpoint" {
  name        = "DB_HOST"
  description = "Database endpoint for the application"
  type        = "String"
  value       = split(":", aws_db_instance.mariadb_master.endpoint)[0]
}


