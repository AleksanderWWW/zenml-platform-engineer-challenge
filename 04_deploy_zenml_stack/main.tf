provider "zenml" {}

resource "zenml_service_connector" "aws" { ... }         # AWS auth for S3/ECR
resource "zenml_stack_component" "artifact_store" { ... } # S3
resource "zenml_stack_component" "container_registry" { ... } # ECR

resource "zenml_service_connector" "k8s" { ... }         # Kubernetes auth
resource "zenml_stack_component" "orchestrator" { ... }  # flavor = kubernetes

resource "zenml_stack" "stack" {
  components = {
    artifact_store     = zenml_stack_component.artifact_store.id
    container_registry = zenml_stack_component.container_registry.id
    orchestrator       = zenml_stack_component.orchestrator.id
  }
}
