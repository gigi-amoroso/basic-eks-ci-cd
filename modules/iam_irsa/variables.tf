variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN for the EKS cluster (e.g., from module.eks.cluster_oidc_issuer_arn)"
  type        = string
}

variable "region" {
  type = string
  default = "us-east-1"
}

variable "acc_id" {
  type = number
}

variable "db_user" {
  description = "dev db id"
}

variable "rds_resource_ids" {
  description = "Map of RDS resource IDs keyed by environment"
  type        = map(string)
}

variable "s3_bucket_names" {
  description = "bucket names"
  type        = map(string)
}

variable "eks_aws_auth_ready" {
  type = string
}

variable "namespace_dev" {
  type = string
}

variable "namespace_prod" {
  type = string
}

variable "db_password" {
}

variable "service_account_dev_word" {
  default = "wordpress-rds-dev-sa"
}

variable "service_account_prod_word" {
  default = "wordpress-rds-prod-sa"
}