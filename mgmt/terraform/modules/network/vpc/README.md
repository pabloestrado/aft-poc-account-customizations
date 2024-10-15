<!-- BEGIN_TF_DOCS -->
# MODULE: Isolated VPC

## General

This module creates a basic empty VPC, and is kept as a module to allow
unified approach to describing uncommon architectures - e.g., to
describe a database-only VPC connected to other VPCs via a Transit
Gateway or VPC Peering in the same way as the most common 3-Tier
structure.

Also used by other VPC modules as a dependency.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cidr | IPv4 CIDR prefix to associate with the VPC. NB: Though VPC supports more than one range - this feature is too rarely used and is not covered by the module | `string` | n/a | yes |
| ipv6 | Set the parameter to true allows AWS to assign the VPC Amazon-provided IPv6 CIDR range| `bool` | `true` | no |
| name | Name for the VPC, also returned as output for convenience | `string` | n/a | yes |
| tags | Extra tags to add to the resources and VPC in addition to \"Name\" | `map(string)` | `{}` | yes |
| vpc_tags | A map of tags to assign to the VPC only | `map(string)` | `{}` | yes |

## Outputs

| Name | Description |
|------|-------------|
| id, name | ID (suitable for \"vpc_id\" parameter) and name of the VPC |
| ipv4_cidr, ipv6_cidr | IPv4, IPv6 CIDR ranges associated with the VPC |
| route_table | Default VPC route table ID |

## Example

Full example of database-only VPC:

```terraform
    ### VPC: DB
    module "db-vpc" {
      source = "../../modules/vpc/isolated/"

      name = "${local.basename}-DB"
      cidr = var.db_vpc_cidr
      tags = local.base_tags
    }

    ### VPC Subnets: DB
    module "db-subnets" {
      source = "../../modules/vpc/subnets/"

      vpc_id = module.db-vpc.id

      basename = "${local.basename}-DB"

      zones  = local.zone_names
      prefix = var.db_vpc_cidr
      bits   = 8
      base   = 0

      route_table = module.db-vpc.rt_default

      tags = merge(local.base_tags, {
        Tier = "DB"
      })
    }
```

---
Copyright (c) 2023 Automat-IT
<!-- END_TF_DOCS -->