locals {
    db_secret_name = "zenml-db-creds"
}

module "k8s" {
    source = "../../module/k8s"

    state_bucket_name = "tf-state-1234509876"
    state_bucket_path = "dev/infra/terraform.tfstate"

    db_secret_name = locals.db_secret_name
}

resource "helm_release" "zenml" {
  name             = "zenml"
  repository       = "oci://public.ecr.aws/zenml"
  chart            = "zenml"
  namespace        = "zenml"
  
  depends_on = [module.k8s]

  values = [
    file("${path.module}/zenml_values.yaml")
  ]

  set = [
    {
        name = "database.passwordSecretRef.name",
        value = locals.db_secret_name
    }
  ]
}
