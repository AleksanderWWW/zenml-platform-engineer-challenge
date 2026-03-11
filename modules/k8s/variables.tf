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
