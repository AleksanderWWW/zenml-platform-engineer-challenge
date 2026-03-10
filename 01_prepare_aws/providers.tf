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
