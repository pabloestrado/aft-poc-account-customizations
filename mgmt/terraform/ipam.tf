module "ipam" {
  source = "aws-ia/ipam/aws"
  # See https://github.com/aws-ia/terraform-aws-ipam/blob/main/examples/single_scope_ipv4/main.tf

  top_cidr = ["10.192.0.0/10"]
  top_name = local.basename

  pool_configurations = {
    eu-west-2 = {
      description = "eu-west-2 pool"
      cidr        = ["10.192.0.0/11"]
      locale      = data.aws_region.current.id
      sub_pools = {
        management = {
          netmask_length = 13
          name           = "Management"
          tags = {
            env = "management"
          }
        }

        sandbox = {
          name                 = "Sandbox"
          netmask_length       = 13
          ram_share_principals = ["arn:aws:organizations::444629336067:ou/o-mmrpss74fy/ou-2ure-5cusy3i7"]
          tags = {
            env = "sandbox"
          }
        }

        dev = {
          name           = "Dev"
          netmask_length = 14
          tags = {
            env = "dev"
          }
        }
        prod = {
          name           = "Prod"
          netmask_length = 14
          tags = {
            env = "prod"
          }
        }
      }
    }
  }
}
