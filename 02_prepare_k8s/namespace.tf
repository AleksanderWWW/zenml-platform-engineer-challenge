resource "kubernetes_namespace_v1" "zenml_namespace" {
  metadata {
    name = "zenml"
  }
}
