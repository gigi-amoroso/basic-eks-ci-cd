terraform {
  required_version = ">= 1.10"
  required_providers {
    aws        = { source = "hashicorp/aws", version = "5.86.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = "2.35.1" }
    helm       = { source = "hashicorp/helm", version = "3.0.0-pre1" }
  }
}

data "aws_caller_identity" "current" {}

output "caller_identity" {
  value = data.aws_caller_identity.current
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.18.1"
  name    = var.cluster_name
  cidr    = var.vpc_cidr
  azs             = var.availability_zones
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  enable_nat_gateway  = true
  single_nat_gateway  = false
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "kubernetes.io/role/elb"                      = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}"   = "owned"
    "kubernetes.io/role/internal-elb"               = "1"
  }
}

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
  acc_id             = var.acc_id
}

module "iam_irsa" {
  source            = "./modules/iam_irsa"
  eks_cluster_name  = var.cluster_name
  acc_id            = var.acc_id
  db_user           = var.db_username
  oidc_provider_arn = module.eks.cluster_oidc_issuer_arn
  rds_resource_ids  = local.rds_resource_ids
  s3_bucket_names   = local.s3_bucket_names
  eks_aws_auth_ready = module.eks.aws_auth_ready
}

module "acm" {
  source         = "./modules/acm"
  domain_name    = var.domain_name
  hosted_zone_id = var.hosted_zone_id
}

module "helm" {
  source = "./modules/helm"
  eks_cluster_name                           = var.cluster_name
  aws_region                                 = var.aws_region
  aws_load_balancer_controller_role_arn      = module.iam_irsa.aws_load_balancer_controller_role_arn
  external_dns_role_arn                      = module.iam_irsa.external_dns_role_arn
  csi_driver_role_arn                        = module.iam_irsa.csi_driver_role_arn
  aws_load_balancer_controller_chart_version = var.aws_load_balancer_controller_chart_version
  external_dns_chart_version                 = var.external_dns_chart_version
  node_termination_handler_chart_version     = var.node_termination_handler_chart_version
  external_dns_namespace                     = var.external_dns_namespace
  depends_on = [module.eks]
}

module "rds" {
  for_each         = local.environments
  source           = "./modules/rds"
  environment      = each.key
  db_name          = each.value.db_name
  db_username      = var.db_username
  db_password      = var.db_password
  vpc_id           = module.vpc.vpc_id
  private_subnets  = module.vpc.private_subnets
  eks_cluster_cidr = var.vpc_cidr
}

module "s3" {
  for_each    = local.environments
  source      = "./modules/s3"
  bucket_name = "${var.s3_bucket_base}-${each.value.s3_suffix}"
}
