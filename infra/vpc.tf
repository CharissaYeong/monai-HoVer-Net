data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project}-vpc"
  cidr = "10.0.0.0/16"

  # Collects the first 3 active availability zones for the region
  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  # Explicit network topology layout allocation
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  intra_subnets   = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]

  # Enable a Single NAT Gateway to save massive FinOps idle infrastructure costs
  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  # CRITICAL: AWS EKS requires specific tags to map network load balancers automatically
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    # Matches the cluster name defined in your eks.tf config
    "kubernetes.io/cluster/${var.project}-cluster" = "shared"
  }

  tags = {
    Deployment = "Networking-Base"
  }
}