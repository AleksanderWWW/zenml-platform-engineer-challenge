resource "helm_release" "prometheus_operator" {
  name       = "prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"
  version    = "80.5.0"

  create_namespace = true

  wait = true

  set =[{
    name  = "grafana.adminPassword"
    value = "admin123"
  }]
}

resource "helm_release" "envoy_gateway" {
  name       = "eg"
  repository = "oci://docker.io/envoyproxy"
  chart      = "gateway-helm"
  version    = "1.6.2"

  namespace        = "envoy-gateway-system"
  create_namespace = true

  wait = true
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "oci://quay.io/jetstack/charts"
  chart      = "cert-manager"
  version    = "v1.19.4"

  namespace        = "cert-manager"
  create_namespace = true

  set = [
    {
      name  = "crds.enabled"
      value = "true"
    },
    {
      name = "extraArgs"
      value = "{--enable-gateway-api}"
    }
  ]

  wait = true
}

resource "helm_release" "mysql" {
  name       = "zenml-db"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "mysql"
  version    = "11.1.23"
  namespace  = "mysql"
  create_namespace = true

  wait = true

  set = [
  {
    name  = "auth.database"
    value = "zenml"
  }

  {
    name  = "auth.username"
    value = var.db_username
  }
  {
    name  = "auth.password"
    value = var.db_password
  }

  # Storage Configuration (EBS)
  {
    name  = "primary.persistence.enabled"
    value = "true"
  }

  {
    name  = "primary.persistence.size"
    value = "10Gi"
  }

  {
    name  = "primary.persistence.storageClass"
    value = kubernetes_storage_class.ebs_sc.name
  }

  # Resources & Best Practices
  {
    name  = "primary.resources.requests.cpu"
    value = "250m"
  }

  {
    name  = "primary.resources.limits.memory"
    value = "512Mi"
  }
  ]
}

resource "kubernetes_namespace_v1" "zenml_namespace" {
  metadata {
    name = "zenml"
  }
}

# 1. Define your variables
variable "db_username" {
  description = "The username for the database"
  type        = string
  sensitive   = true
  default     = "admin_user"
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}

variable "db_secret_name" {
  type = string
}

# 2. Provision the Kubernetes Secret
resource "kubernetes_secret" "app_db_creds" {
  metadata {
    name      = var.db_secret_name
    namespace = kubernetes_namespace_v1.zenml_namespace.metadata[0].name
    
    labels = {
      managed-by = "terraform"
    }
  }

  type = "Opaque"

  data = {
    username = var.db_username
    password = var.db_password
  }
}

resource "kubernetes_storage_class" "ebs_sc" {
  metadata {
    name = "ebs-sc"
  }

  storage_provisioner = "ebs.csi.aws.com"

  parameters = {
    type      = "gp3"
    fsType    = "ext4"
     # TODO: encrypt

  }

  volume_binding_mode = "WaitForFirstConsumer"
}

variable "state_bucket_name" {
  type = string
}

variable "state_bucket_path" {
  type = string
}

variable "state_bucket_region" {
  type = string
  default = "us-east-1"
}

data "terraform_remote_state" "aws_infra" {
  backend = "s3"

  config = {
    bucket = var.state_bucket_name
    key    = var.state_bucket_path
    region = var.state_bucket_region
  }
}

locals {
  zenml_role_arn = data.terraform_remote_state.aws_infra.outputs.zenml_role_arn
}

resource "kubernetes_service_account" "zenml" {
  metadata {
    name      = "zenml"
    namespace =  kubernetes_namespace_v1.zenml_namespace.metadata[0].name

    annotations = {
      "eks.amazonaws.com/role-arn" = local.zenml_role_arn
    }
    
    labels = {
      "app.kubernetes.io/name" = "zenml"
      "managed-by"             = "terraform"
    }
  }
}
