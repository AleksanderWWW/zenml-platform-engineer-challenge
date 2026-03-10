module "ebs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 6.0"

  name                  = "ebs-csi"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

resource "aws_iam_policy" "zenml_platform_policy" {
  name        = "${var.project_name}-platform-policy"
  description = "Allows ZenML to manage S3 artifacts and ECR images"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # S3 Permissions
      {
        Action   = ["s3:ListBucket", "s3:GetBucketLocation"]
        Effect   = "Allow"
        Resource = [var.artifact_bucket_arn]
      },
      {
        Action   = ["s3:PutObject", "s3:GetObject", "s3:DeleteObject"]
        Effect   = "Allow"
        Resource = ["${var.artifact_bucket_arn}/*"]
      },
      # ECR Permissions (Required for image building/storing)
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Effect   = "Allow"
        Resource = "*" # ECR GetAuthorizationToken requires "*"
      }
    ]
  })
}

module "zenml_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 5.0"

  role_name = "${var.project_name}-server-role"

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["zenml:zenml"]
    }
  }

  role_policy_arns = {
    platform_access = aws_iam_policy.zenml_platform_policy.arn
  }
}
