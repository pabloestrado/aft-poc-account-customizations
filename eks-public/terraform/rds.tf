module "sg" {
  source = "terraform-aws-modules/security-group/aws//modules/postgresql"

  name        = "web-server"
  description = "Security group for web-server with HTTP ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = module.vpc.private_subnets_cidr_blocks
}

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${local.basename}-db"

  engine            = "postgres"
  engine_version    = "16.3"
  instance_class    = "db.t4g.micro"
  allocated_storage = 5

  db_name  = "app"
  username = "admin"

  vpc_security_group_ids = [module.sg.security_group_id]

  multi_az = false

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = module.vpc.private_subnets

  # DB parameter group
  family = "postgres16.3"
}
