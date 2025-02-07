resource "aws_iam_policy" "lb_controller_policy" {
  name        = "${var.eks_cluster_name}-aws-load-balancer-controller-policy"
  description = "Custom policy for AWS Load Balancer Controller"
  policy      = file("${path.module}/iam_policy.json")
}

module "aws_load_balancer_controller_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.52.2"

  # Use role_name instead of name. This value is passed in from the root module.
  role_name = "${var.eks_cluster_name}-aws-load-balancer-controller-role"

  # Provide the OIDC provider info as a map. Each key in the map should have:
  # - provider_arn (the ARN for your OIDC provider)
  # - namespace_service_accounts, with each value in the format "namespace:serviceaccount"
  oidc_providers = {
    lb_controller = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller-iam-service-account"]
    }
  }

  # Attach your custom policy by passing its ARN in role_policy_arns.
  role_policy_arns = {
    lb_controller_policy = aws_iam_policy.lb_controller_policy.arn
  }
}

module "external_dns_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.52.2"

  role_name = "${var.eks_cluster_name}-external-dns-role"

  oidc_providers = {
    external_dns = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:external-dns-service-account"]
    }
  }

  # For a managed policy, simply pass the ARN.
  role_policy_arns = {
    AmazonRoute53FullAccess = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
  }
}

output "aws_load_balancer_controller_role_arn" {
  description = "ARN for the AWS Load Balancer Controller role"
  value       = module.aws_load_balancer_controller_role.iam_role_arn
}

output "external_dns_role_arn" {
  description = "ARN for the External DNS role"
  value       = module.external_dns_role.iam_role_arn
}
