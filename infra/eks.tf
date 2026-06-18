module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "${var.project}-cluster"
  kubernetes_version = "1.31"

  endpoint_public_access = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    system_nodes = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }

    gpu_workers = {
      ami_type       = "AL2_x86_64_GPU"
      instance_types = ["t3.medium"]

      min_size     = 0
      max_size     = 5
      desired_size = 1

      labels = {
        "k8s.amazonaws.com/accelerator" = "nvidia-tesla-g5"
        "instance-type"                 = "gpu-worker"
      }

      # enable_bootstrap_user_data = true
    }
  }

  tags = {
    Deployment = "Compute-Plane"
  }
}