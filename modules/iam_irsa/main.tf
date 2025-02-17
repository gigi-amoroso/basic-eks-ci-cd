locals {
  common_s3_actions = ["s3:*"]

  # Define each IAM role with its settings
  iam_roles = {
    lb_controller = {
      role_name       = "${var.eks_cluster_name}-aws-load-balancer-controller-role"
      namespace       = "kube-system"
      service_account = "aws-load-balancer-controller-iam-service-account"
      policy          = aws_iam_policy.lb_controller_policy.arn
    }
    external_dns = {
      role_name       = "${var.eks_cluster_name}-external-dns-role"
      namespace       = "kube-system"
      service_account = "external-dns-service-account"
      policy          = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
    }
    csi_driver = {
      role_name       = "${var.eks_cluster_name}-AmazonEKS_EBS_CSI_DriverRole"
      namespace       = "kube-system"
      service_account = "aws-ebs-csi-driver-sa"
      policy          = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    }
    rds_dev = {
      role_name       = "${var.eks_cluster_name}-rds-dev-sa"
      namespace       = "wordpress-dev"
      service_account = "wordpress-rds-dev-sa"
      policy          = aws_iam_policy.rds_dev_policy.arn
    }
    rds_prod = {
      role_name       = "${var.eks_cluster_name}-rds-prod-sa"
      namespace       = "wordpress-prod"
      service_account = "wordpress-rds-prod-sa"
      policy          = aws_iam_policy.rds_prod_policy.arn
    }
  }
}

# IAM policy definitions (unchanged)
resource "aws_iam_policy" "lb_controller_policy" {
  name        = "${var.eks_cluster_name}-aws-load-balancer-controller-policy"
  description = "Custom policy for AWS Load Balancer Controller"
  policy      = file("${path.module}/iam_policy.json")
}

resource "aws_iam_policy" "rds_dev_policy" {
  name        = "${var.eks_cluster_name}-rds-dev-policy"
  description = "Policy to allow RDS connection and S3 access for dev database"
  policy      = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["rds-db:connect"],
        Resource = [
          "arn:aws:rds-db:${var.region}:${var.acc_id}:dbuser:${var.rds_resource_ids["dev"]}/${var.db_user}"
        ]
      },
      {
        Effect   = "Allow",
        Action   = local.common_s3_actions,
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_names["dev"]}",
          "arn:aws:s3:::${var.s3_bucket_names["dev"]}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "rds_prod_policy" {
  name        = "${var.eks_cluster_name}-rds-prod-policy"
  description = "Policy to allow RDS connection and S3 access for prod database"
  policy      = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["rds-db:connect"],
        Resource = [
          "arn:aws:rds-db:${var.region}:${var.acc_id}:dbuser:${var.rds_resource_ids["prod"]}/${var.db_user}"
        ]
      },
      {
        Effect   = "Allow",
        Action   = local.common_s3_actions,
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_names["prod"]}",
          "arn:aws:s3:::${var.s3_bucket_names["prod"]}/*"
        ]
      }
    ]
  })
}

# Single module block to create all IAM roles via iteration
module "iam_roles" {
  source   = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  for_each = local.iam_roles
  version  = "5.52.2"

  role_name = each.value.role_name

  oidc_providers = {
    "${each.key}" = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${each.value.namespace}:${each.value.service_account}"]
    }
  }

  role_policy_arns = {
    "${each.key}" = each.value.policy
  }
}

# Outputs
output "iam_role_arns" {
  description = "Map of IAM role ARNs created for service accounts"
  value = { for key, mod in module.iam_roles : key => mod.iam_role_arn }
}