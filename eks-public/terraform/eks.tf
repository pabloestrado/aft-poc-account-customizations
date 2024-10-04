### EKS
# Common
variable "eks_ami_type" { type = string }
variable "eks_instance_types" { type = list(string) }
variable "eks_attach_cluster_primary_security_group" { type = bool }
#System
variable "eks_system_min_size" { type = number }
variable "eks_system_max_size" { type = number }
variable "eks_system_desired_size" { type = number }
variable "eks_system_instance_types" { type = list(string) }


# Create IAM role
resource "aws_iam_role" "eks_role" {
  name = "EKSAccessRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                   = local.basename
  cluster_version                = "1.31"
  cluster_endpoint_public_access = false

  enable_cluster_creator_admin_permissions = true

  access_entries = {
    onelogin-admin = {
      principal_arn = aws_iam_role.eks_role.arn
      type          = "STANDARD"

      policy_associations = {
        admin = {
          policy_arn = "arn:${data.aws_partition.current.partition}:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent    = true
      before_compute = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  # Fargate profiles use the cluster primary security group so these are not utilized
  create_cluster_security_group = true
  create_node_security_group    = false

  cluster_security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = {
      description = "Access from MGMT environment"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = [local.vpc_cidr]
    }
  }

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
    ami_type       = var.eks_ami_type       # "AL2023"
    instance_types = var.eks_instance_types # ["t3.medium"]

    attach_cluster_primary_security_group = var.eks_attach_cluster_primary_security_group # true
  }

  eks_managed_node_groups = {
    system = {
      ami_type       = var.eks_ami_type
      instance_types = var.eks_system_instance_types

      min_size     = var.eks_system_min_size
      max_size     = var.eks_system_max_size
      desired_size = var.eks_system_desired_size

      taints = {
        # This Taint aims to keep just EKS Addons and Karpenter running on this MNG
        # The pods that do not tolerate this taint should run on nodes created by Karpenter
        addons = {
          key    = "CriticalAddonsOnly"
          value  = "true"
          effect = "NO_SCHEDULE"
        },
      }
    }
  }

  tags = merge(local.base_tags, {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = local.basename
  })
}
