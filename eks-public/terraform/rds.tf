module "sg" {
  source = "terraform-aws-modules/security-group/aws//modules/mysql"
  name        = "mysql"
  description = "Security group rds access"
  vpc_id      = module.vpc.vpc_id
  ingress_cidr_blocks = module.vpc.private_subnets_cidr_blocks
}

module "db" {
  source = "terraform-aws-modules/rds/aws"
  identifier = "${local.basename}-db"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t4g.micro"
  allocated_storage = 5
  db_name  = "app"
  username = "admin"
  port     = "3306"
  iam_database_authentication_enabled = true
  vpc_security_group_ids = [module.sg.security_group_id]
  multi_az = false
  # DB subnet group
  create_db_subnet_group = true
  db_subnet_group_use_name_prefix = false
  subnet_ids             = module.vpc.private_subnets
  # DB parameter group
  family = "mysql8.0"
  # DB option group
  major_engine_version = "8.0"
  option_group_use_name_prefix = false
  parameter_group_use_name_prefix = false
}
