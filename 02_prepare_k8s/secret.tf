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

# 2. Provision the Kubernetes Secret
resource "kubernetes_secret" "app_db_creds" {
  metadata {
    name      = "database-credentials"
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
