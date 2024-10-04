locals {
  region = data.aws_region.current.name

  project_name = nonsensitive(data.aws_ssm_parameter.project_name.value)
  project_env  = nonsensitive(data.aws_ssm_parameter.env.value)
  vpc_cidr     = nonsensitive(data.aws_ssm_parameter.vpc_cidr.value)

  basename = "${local.project_name}-${local.project_env}"

  # Base resource-independent tags. Left here for the back compatibility
  base_tags = {
  }
  # Base resource-independent tags
  provider_base_tags = {
    Project     = local.project_name
    Environment = local.project_env
    Managed_by  = "terraform"
    Name        = ""
  }
}
