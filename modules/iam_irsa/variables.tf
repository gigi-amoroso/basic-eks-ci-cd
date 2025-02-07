variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN for the EKS cluster (e.g., from module.eks.cluster_oidc_issuer_arn)"
  type        = string
}
