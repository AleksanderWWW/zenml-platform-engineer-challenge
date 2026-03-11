output "zenml_role_arn" {
    type = string
    description = "ARN of the role to attach to the K8s service account"
    value = module.zenml_irsa_role.arn
}

output "ebs_role_arn" {
    type = string
    description = "ARN of the role that allows to attach EBS to EKS cluster"
    value = module.ebs_csi_irsa.arn
}
