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

  values = [
    <<-EOT
    grafana:
      grafana.ini:
        server:
          root_url: "%(protocol)s://%(domain)s:%(http_port)s/monitoring/"
          serve_from_sub_path: true
        session:
          # This ensures Grafana cookies don't leak to the main app
          cookie_path: /monitoring/
          # Optional: rename the cookie to avoid any conflicts
          cookie_name: grafana_session_monitoring
    EOT
  ]
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
