terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.86.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.35.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.0-pre1"
    }
  }
}

# Create a VPC (using the community VPC module)
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.18.1"

  name = var.cluster_name
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway = true
  single_nat_gateway = false

  tags = {
    Name = var.cluster_name
  }
}

# EKS cluster module (using terraform-aws-modules/eks/aws)
module "eks" {
  source             = "./modules/eks"
  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version
  vpc_id             = module.vpc.vpc_id
  private_subnets    = module.vpc.private_subnets
  public_subnets     = module.vpc.public_subnets
  desired_capacity   = var.desired_capacity
  max_capacity       = var.max_capacity
  node_instance_type = var.node_instance_type
  availability_zones = var.availability_zones
  aws_region         = var.aws_region
}

# IAM roles for IRSA (for AWS Load Balancer Controller and External DNS)
module "iam_irsa" {
  source            = "./modules/iam_irsa"
  eks_cluster_name  = var.cluster_name # Here you pass your root variable (for example, var.cluster_name)
  oidc_provider_arn = module.eks.cluster_oidc_issuer_arn
}


# ACM certificate module (using aws_acm_certificate and DNS validation via Route53)
module "acm" {
  source         = "./modules/acm"
  domain_name    = var.domain_name
  hosted_zone_id = var.hosted_zone_id
}

# Helm releases for AWS Load Balancer Controller, External DNS, and AWS Node Termination Handler
module "helm" {
  source                                     = "./modules/helm"
  eks_cluster_name                           = var.cluster_name
  aws_region                                 = var.aws_region
  aws_load_balancer_controller_role_arn      = module.iam_irsa.aws_load_balancer_controller_role_arn
  external_dns_role_arn                      = module.iam_irsa.external_dns_role_arn
  aws_load_balancer_controller_chart_version = var.aws_load_balancer_controller_chart_version
  external_dns_chart_version                 = var.external_dns_chart_version
  node_termination_handler_chart_version     = var.node_termination_handler_chart_version
  external_dns_namespace                     = var.external_dns_namespace
}
