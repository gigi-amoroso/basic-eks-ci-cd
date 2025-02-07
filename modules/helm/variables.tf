variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_load_balancer_controller_role_arn" {
  description = "IAM Role ARN for the AWS Load Balancer Controller"
  type        = string
}

variable "external_dns_role_arn" {
  description = "IAM Role ARN for External DNS"
  type        = string
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
