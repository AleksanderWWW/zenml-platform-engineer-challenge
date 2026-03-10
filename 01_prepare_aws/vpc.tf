data "aws_availability_zones" "available" {}

# -------------------------------
# VPC (minimal: 3 private + 3 public subnets)
# -------------------------------

# Adjust CIDR as needed
# We use public subnets to simplify image pulling from ECR
# In a more air-gapped scenario one would host their own registry inside the cluster

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.5.0"

  name = "optima-eks"
  cidr = "10.1.0.0/16"

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  public_subnets  = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1" # Tells AWS to use these for Public LoadBalancers
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1" # Tells AWS to use these for Internal LoadBalancers
  }
}
