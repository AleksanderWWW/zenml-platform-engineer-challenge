# -----------------------------------------------------------------------------
# ZENML PLATFORM ENGINEER CHALLENGE - INFRASTRUCTURE
# -----------------------------------------------------------------------------
#
# Your goal: Deploy a production-ready ZenML OSS server on AWS.
#
# This file is a starting point. You should organize your Terraform code
# into modules as you see fit (e.g., networking/, compute/, database/).
#
# -----------------------------------------------------------------------------
# RECOMMENDED ARCHITECTURE (EKS + RDS MySQL)
# -----------------------------------------------------------------------------
#
# ┌─────────────────────────────────────────────────────────────────────────┐
# │                              AWS VPC                                     │
# │  ┌────────────────────────┐    ┌────────────────────────┐               │
# │  │    Public Subnets      │    │    Private Subnets     │               │
# │  │  ┌──────────────────┐  │    │  ┌──────────────────┐  │               │
# │  │  │       ALB        │──┼────┼─▶│   EKS Cluster    │  │               │
# │  │  └──────────────────┘  │    │  │   (ZenML Helm)   │  │               │
# │  └────────────────────────┘    │  └────────┬─────────┘  │               │
# │                                │           │            │               │
# │                                │  ┌────────▼─────────┐  │               │
# │                                │  │    RDS MySQL     │  │               │
# │                                │  └──────────────────┘  │               │
# │                                └────────────────────────┘               │
# └─────────────────────────────────────────────────────────────────────────┘
#
# -----------------------------------------------------------------------------
# ALTERNATIVE: EKS + IN-CLUSTER MySQL
# -----------------------------------------------------------------------------
#
# You may deploy MySQL as a Kubernetes service instead of RDS.
# This demonstrates K8s stateful workload skills (PVCs, StatefulSets).
#
# NOTE: ZenML OSS only supports MySQL (not PostgreSQL).
#
# ┌─────────────────────────────────────────────────────────────────────────┐
# │                              AWS VPC                                     │
# │  ┌────────────────────────┐    ┌────────────────────────┐               │
# │  │    Public Subnets      │    │    Private Subnets     │               │
# │  │  ┌──────────────────┐  │    │  ┌──────────────────┐  │               │
# │  │  │       ALB        │──┼────┼─▶│   EKS Cluster    │  │               │
# │  │  └──────────────────┘  │    │  │ ┌──────────────┐ │  │               │
# │  └────────────────────────┘    │  │ │ ZenML (Helm) │ │  │               │
# │                                │  │ └──────┬───────┘ │  │               │
# │                                │  │        │         │  │               │
# │                                │  │ ┌──────▼───────┐ │  │               │
# │                                │  │ │ MySQL (K8s)  │ │  │               │
# │                                │  │ │ + PVC (EBS)  │ │  │               │
# │                                │  │ └──────────────┘ │  │               │
# │                                │  └──────────────────┘  │               │
# │                                └────────────────────────┘               │
# └─────────────────────────────────────────────────────────────────────────┘
#
# -----------------------------------------------------------------------------
# ALTERNATIVE ARCHITECTURES
# -----------------------------------------------------------------------------
#
# You may use ECS, App Runner, or other containerized solutions.
# If you choose an alternative, document your reasoning.
#
# -----------------------------------------------------------------------------
# RESOURCES
# -----------------------------------------------------------------------------
#
# - ZenML Helm Chart: https://artifacthub.io/packages/helm/zenml/zenml
# - ZenML Self-Hosting Docs: https://docs.zenml.io/getting-started/deploying-zenml
# - EKS Best Practices: https://aws.github.io/aws-eks-best-practices/
#
# -----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    backend "s3" {
      bucket         = ""
      key            = "production/terraform.tfstate"
      region         = var.region
      encrypt        = true
      
      # This enables native S3 locking without DynamoDB
      use_lockfile   = true 
      
      consistency    = "strong" 
    }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "zenml-platform-challenge"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}


# -----------------------------------------------------------------------------
# TODO: YOUR INFRASTRUCTURE CODE GOES HERE
# -----------------------------------------------------------------------------
#
# Suggested order:
# 1. VPC and Networking (subnets, security groups, NAT gateway)
# 2. MySQL Database — choose one:
#    a) RDS MySQL (managed)
#    b) MySQL as K8s StatefulSet with PVC (in-cluster)
# 3. EKS Cluster (or ECS/App Runner)
# 4. ZenML Deployment (Helm release or ECS task)
# 5. ALB with TLS (using ACM certificate)
# 6. Observability (CloudWatch, alarms)
#
# Tips:
# - ZenML OSS only supports MySQL (not PostgreSQL)
# - Use data sources to reference existing resources (e.g., ACM certificates)
# - Use locals for computed values and naming conventions
# - Consider using community modules (e.g., terraform-aws-modules/vpc/aws)
# - For in-cluster MySQL: consider Bitnami Helm chart or a simple StatefulSet
#

# -----------------------------------------------------------------------------
# OUTPUTS
# -----------------------------------------------------------------------------

# output "zenml_server_url" {
#   description = "URL to access the ZenML server"
#   value       = "https://${your_domain_or_alb_dns}"
# }

# output "database_endpoint" {
#   description = "Database endpoint (RDS or K8s service)"
#   value       = "your-database-endpoint"
#   sensitive   = true
# }
