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

module "csi_driver_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.52.2"

  role_name = "${var.eks_cluster_name}-AmazonEKS_EBS_CSI_DriverRole"

  oidc_providers = {
    csi_driver = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-ebs-csi-driver-sa"]
    }
  }

  # For a managed policy, simply pass the ARN.
  role_policy_arns = {
    AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  }
}

# Create an IAM policy for the dev database access
resource "aws_iam_policy" "rds_dev_policy" {
  name        = "${var.eks_cluster_name}-rds-dev-policy"
  description = "Policy to allow RDS connection for dev database"
  policy      = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "rds-db:connect"
        ],
        Resource = [
          "arn:aws:rds-db:${var.region}:${var.acc_id}:dbuser:${var.rds_resource_ids["dev"]}/${var.db_user}"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "rds_prod_policy" {
  name        = "${var.eks_cluster_name}-rds-prod-policy"
  description = "Policy to allow RDS connection for prod database"
  policy      = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "rds-db:connect"
        ],
        Resource = [
          "arn:aws:rds-db:${var.region}:${var.acc_id}:dbuser:${var.rds_resource_ids["prod"]}/${var.db_user}"
        ]
      }
    ]
  })
}

module "rds_dev_sa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.52.2"

  role_name = "${var.eks_cluster_name}-rds-dev-sa"

  oidc_providers = {
    rds_dev = {
      provider_arn               = var.oidc_provider_arn
      # Format: "namespace:serviceaccount-name"
      namespace_service_accounts = ["wordpress-dev:wordpress-rds-dev-sa"]
    }
  }

  # Attach the dev RDS access policy
  role_policy_arns = {
    rds_dev = aws_iam_policy.rds_dev_policy.arn
  }
}

module "rds_prod_sa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.52.2"

  role_name = "${var.eks_cluster_name}-rds-prod-sa"

  oidc_providers = {
    rds_prod = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["wordpress-prod:wordpress-rds-prod-sa"]
    }
  }

  # Attach the prod RDS access policy
  role_policy_arns = {
    rds_prod = aws_iam_policy.rds_prod_policy.arn
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

output "csi_driver_role_arn" {
  description = "ARN for the AWS Load Balancer Controller role"
  value       = module.csi_driver_role.iam_role_arn
}
