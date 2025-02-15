variable "environment" {
  description = "Environment (dev or prod)"
  type        = string
}

variable "db_name" {
  description = "Database name to create on the instance"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "VPC ID where the DB instance will reside"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs for the DB instance"
  type        = list(string)
}

variable "eks_cluster_cidr" {
  description = "CIDR block for EKS cluster nodes (used for RDS ingress)"
  type        = string
}