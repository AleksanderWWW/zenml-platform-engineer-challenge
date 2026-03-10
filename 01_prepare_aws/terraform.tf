terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
      bucket         = "tf-state-1234509876"
      key            = "production/terraform.tfstate"
      region         = "us-east-1"
      encrypt        = true
      
      # This enables native S3 locking without DynamoDB
      use_lockfile   = true
    }
}
