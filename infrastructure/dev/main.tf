locals {
  eks_name = "zenml-eks"
  k8s_version = "1.34"
  env = "dev"
}

module "iam" {
    source = "../../modules/iam"

    env = locals.env
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.5.0"

  name = "zenml-vpc-${locals.env}"
  cidr = "10.1.0.0/16"

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  public_subnets  = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${locals.eks_name}-${locals.env}" = "shared"
    "kubernetes.io/role/elb"                    = "1" # Tells AWS to use these for Public LoadBalancers
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${locals.eks_name}-${locals.env}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1" # Tells AWS to use these for Internal LoadBalancers
  }
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "${locals.eks_name}-${locals.env}"
  kubernetes_version = locals.kubernetes_version

  addons = {
    coredns                = {}
    kube-proxy             = {}
    vpc-cni                = { before_compute = true }
    eks-pod-identity-agent = { before_compute = true }

    aws-ebs-csi-driver = { service_account_role_arn = module.iam.ebs_role_arn }
  }

  enable_cluster_creator_admin_permissions = true
  endpoint_public_access                   = true

  compute_config = {
    enabled = false
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  # ---------------------------
  # Node group definition
  # ---------------------------
  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.medium"]
      ami_type       = "BOTTLEROCKET_x86_64"
      desired_size   = 5
      min_size       = 5
      max_size       = 5
    },
  }
}

resource "null_resource" "update_kubeconfig" {
  depends_on = [module.eks]

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region us-east-1 --name ${module.eks.cluster_name}"
  }
}

module "stack_components" {
    source = "../../modules/stack_components"

    env = locals.env
}
