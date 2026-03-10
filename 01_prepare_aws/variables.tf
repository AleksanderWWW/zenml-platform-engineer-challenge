variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "zenml"
}

variable "should_update_kubeconfig" {
  type        = bool
  description = "Whether to automatically update the kubeconfig after EKS creation"
  default     = true
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
  default     = "optima"
}

variable "kubernetes_version" {
  type        = string
  description = "K8s version for the EKS cluster"
  default     = "1.34"
}