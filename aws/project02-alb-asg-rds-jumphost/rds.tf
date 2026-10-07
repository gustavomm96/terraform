# Criar a subnet para suportar o rds
resource "aws_db_subnet_group" "rds" {
  provider   = aws.app
  name       = "db-subnet-group-rds"
  subnet_ids = aws_subnet.rds_private[*].id

  tags = {
    Name = "db-subnet-group-rds"
  }
}

# Criar o server db
resource "aws_db_instance" "mariadb" {
  provider   = aws.app
  identifier = "db-gm-mariadb-app"

  engine            = "mariadb"
  engine_version    = "10.11.19" # ou versão disponível na sua região
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp2"

  db_name  = "gmappdb"
  username = var.db_user
  password = var.db_pwd

  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible = false
  skip_final_snapshot = true

  backup_retention_period = 0


  tags = merge(local.common_tags, {
    Name = "rds-mariadb-gmapp"
  })
}