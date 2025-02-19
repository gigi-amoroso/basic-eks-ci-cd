variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS Cluster name"
  type        = string
  default     = "eks-acg"
}

variable "acc_id" {
  description = "account id"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.32"
}

variable "desired_capacity" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 3
}

variable "max_capacity" {
  description = "Max number of worker nodes"
  type        = number
  default     = 5
}

variable "node_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnets" {
  description = "List of public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets" {
  description = "List of private subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "domain_name" {
  description = "Domain name for ACM certificate"
  type        = string
}

variable "hosted_zone_id" {
  description = "Route53 Hosted Zone ID"
  type        = string
}

variable "aws_load_balancer_controller_chart_version" {
  description = "Helm chart version for aws-load-balancer-controller"
  type        = string
  default     = "1.11.0"
}

variable "external_dns_chart_version" {
  description = "Helm chart version for external-dns"
  type        = string
  default     = "1.15.1"
}

variable "node_termination_handler_chart_version" {
  description = "Helm chart version for aws-node-termination-handler"
  type        = string
  default     = "0.21.0"
}

variable "external_dns_namespace" {
  description = "Namespace for external-dns deployment"
  type        = string
  default     = "kube-system"
}

variable "db_username" {
  description = "Database username (same for both envs)"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database password (same for both envs)"
  type        = string
  default     = "admin123"
  sensitive   = true
}

variable "s3_bucket_base" {
  description = "Base name for S3 buckets; environment suffix will be appended"
  type        = string
  default     = "my-wordpress-media"
}

variable "repo_name" {
  default     = "wordpress-helm-chart"
  description = "repo name for codecommit"
}

variable "service_account_dev_word" {
  default = "wordpress-rds-dev-sa"
}

variable "service_account_prod_word" {
  default = "wordpress-rds-prod-sa"
}