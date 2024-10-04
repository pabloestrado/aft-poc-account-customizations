### EKS
# Common
eks_ami_type                              = "AL2023_x86_64_STANDARD"
eks_instance_types                        = ["t3.medium"]
eks_attach_cluster_primary_security_group = false
# System
eks_system_min_size       = 1
eks_system_max_size       = 1
eks_system_desired_size   = 1
eks_system_instance_types = ["t3.medium"]
