terraform {
  required_version = ">= 1.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
  }

  backend "s3" {
      bucket         = "tf-state-1234509876"
      key            = "dev/deployment/terraform.tfstate"
      region         = "us-east-1"
      encrypt        = true
      
      # This enables native S3 locking without DynamoDB
      use_lockfile   = true
    }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
