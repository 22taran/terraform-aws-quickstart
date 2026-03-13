module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "7.1.0"

  identifier = "${var.project_name}-${var.engine}"

  engine               = var.engine
  engine_version       = var.engine_version
  family               = coalesce(var.family, "${var.engine}${split(".", var.engine_version)[0]}")
  major_engine_version = split(".", var.engine_version)[0]
  instance_class       = var.instance_class

  allocated_storage = var.allocated_storage

  db_name                     = var.db_name
  username                    = var.db_username
  manage_master_user_password = true
  port                        = var.port

  multi_az               = var.multi_az
  storage_encrypted      = var.storage_encrypted
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [var.security_group_id]
  publicly_accessible    = false

  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = var.skip_final_snapshot

  tags = merge(var.tags, { Name = "${var.project_name}-postgres" })
}
