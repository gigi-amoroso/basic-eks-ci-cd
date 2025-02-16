module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.33.1"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version
  vpc_id          = var.vpc_id
  subnet_ids      = var.private_subnets  # use subnet_ids instead of subnets
  cluster_endpoint_public_access = true
  enable_cluster_creator_admin_permissions = true
  enable_irsa = true

  eks_managed_node_groups = {
    eks_nodes = {
      desired_size     = var.desired_capacity  
      max_size         = var.max_capacity     
      min_size         = var.desired_capacity
      instance_type    = var.node_instance_type
      capacity_type    = "SPOT"
      private_ip       = true
  }
  }

  tags = {
    Environment = "prod"
    Terraform   = "true"
  }
}

module "aws_auth" {
  
  source = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version         = "20.33.1"
  
  aws_auth_users = [
  {
    userarn  = "arn:aws:iam::${var.acc_id}:user/cloud_user"
    username = "cloud_user"
    groups   = ["system:masters"]
  }, 
]
 /* aws_auth_roles = [
  {
      rolearn  = "arn:aws:iam::${var.acc_id}:role/TerraformExecutionRole"
      username = "TerraformExecutionRole"
      groups   = ["system:masters"]
  },
  ]*/
  depends_on = [module.eks.eks_managed_node_groups]
}

resource "null_resource" "wait_for_aws_auth" {
  depends_on = [module.aws_auth]
}
output "aws_auth_ready" {
  value = null_resource.wait_for_aws_auth.id
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
