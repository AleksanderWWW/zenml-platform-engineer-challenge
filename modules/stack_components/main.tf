resource "aws_ecr_repository" "zenml_repo" {
  name                 = "zenml-${var.env}-repository"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_s3_bucket" "artifact_store" {
  bucket = "my-app-artifacts-1234509876-${var.env}"

  tags = {
    Name        = "Artifact Store"
    Environment = "Production"
  }
}

# Enable versioning so you can recover old versions of artifacts
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.artifact_store.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Block all public access (Crucial for security)
resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.artifact_store.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
