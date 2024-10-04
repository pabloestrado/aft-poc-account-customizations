data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "env" {
  name = "/aft/account-request/custom-fields/env"
}

data "aws_ssm_parameter" "project_name" {
  name = "/aft/account-request/custom-fields/project_name"
}

data "aws_ssm_parameter" "vpc_cidr" {
  name = "/aft/account-request/custom-fields/vpc_cidr"
}
