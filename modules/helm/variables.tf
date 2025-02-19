variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "iam_role_arns" {
  description = "Map of IAM role ARNs for service accounts"
  type        = map(string)
}

variable "aws_load_balancer_controller_chart_version" {
  description = "Helm chart version for aws-load-balancer-controller"
  type        = string
}

variable "external_dns_chart_version" {
  description = "Helm chart version for external-dns"
  type        = string
}

variable "node_termination_handler_chart_version" {
  description = "Helm chart version for aws-node-termination-handler"
  type        = string
}

variable "external_dns_namespace" {
  description = "Namespace for external-dns deployment"
  type        = string
}

variable "certificate_arn" {
  
}

variable "hostname" {
  description = "Hostname for the ArgoCD ingress"
  type        = string
}

variable "istio_version" {
  description = "version of istio"
  type        = string
  default = "1.24.3"
}

variable "domain_name" {
  description = "domain name"
}