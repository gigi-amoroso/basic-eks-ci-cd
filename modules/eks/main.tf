module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.33.1"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version
  vpc_id          = var.vpc_id
  subnet_ids      = var.private_subnets  # use subnet_ids instead of subnets

  eks_managed_node_groups = {          # use managed_node_groups instead of node_groups
    eks_nodes = {
      desired_capacity = var.desired_capacity
      max_capacity     = var.max_capacity
      instance_type    = var.node_instance_type
      private_ip       = true
    }
  }

  enable_irsa = true

  tags = {
    Environment = "prod"
    Terraform   = "true"
  }
}


output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}

output "cluster_oidc_issuer_arn" {
  value = module.eks.oidc_provider_arn
}

output "cluster_id" {
  value = module.eks.cluster_id
}
