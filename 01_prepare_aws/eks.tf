module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  addons = {
    coredns                = {}
    kube-proxy             = {}
    vpc-cni                = { before_compute = true }
    eks-pod-identity-agent = { before_compute = true }

    # !! this is crucial for seamless access to EBS from the cluster !!
    aws-ebs-csi-driver = { service_account_role_arn = module.ebs_csi_irsa.arn }
  }

  # Those are set for demo purposes - adjust as needed
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

    # medium instances to handle the UI, simulation scheduler, db server, monitoring stack etc.
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
  count      = var.should_update_kubeconfig ? 1 : 0

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
  }
}
