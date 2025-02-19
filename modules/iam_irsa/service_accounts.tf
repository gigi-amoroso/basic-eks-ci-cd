locals {
  env_configs = {
    dev = {
      bucket_name     = var.s3_bucket_names["dev"]
      namespace       = var.namespace_dev
      service_account = var.service_account_dev_word
      role            = module.iam_roles["rds_dev"].iam_role_arn
    },
    prod = {
      bucket_name     = var.s3_bucket_names["prod"]
      namespace       = var.namespace_prod
      service_account = var.service_account_prod_word
      role            = module.iam_roles["rds_prod"].iam_role_arn
    }
  }
}

resource "kubernetes_namespace" "wordpress" {
  for_each = local.env_configs

  metadata {
    name = each.value.namespace
    labels = {
      "istio-injection" = "enabled"
    }
  }

  depends_on = [ var.eks_aws_auth_ready ]
}

resource "kubernetes_service_account" "wordpress_rds_sa" {
  for_each = local.env_configs

  metadata {
    name      = each.value.service_account
    namespace = each.value.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = each.value.role
    }
  }

  depends_on = [ var.eks_aws_auth_ready ]
}

resource "kubernetes_secret" "wordpress_rds_secret" {
  for_each = local.env_configs

  metadata {
    name      = "wordpress-rds-secret"
    namespace = each.value.namespace
  }

  data = {
    mariadb-password = var.db_password
  }

  type = "Opaque"

  depends_on = [ kubernetes_namespace.wordpress ]
}

resource "kubernetes_secret" "wordpress_s3_secret" {
  for_each = local.env_configs
  metadata {
    name      = "wordpress-s3-secret"
    namespace = each.value.namespace  # e.g., "wordpress-dev"
  }
  data = {
    WORDPRESS_AWS_S3_BUCKET = each.value.bucket_name
    WORDPRESS_AWS_S3_REGION = var.region
  }
  type = "Opaque"
  depends_on = [ kubernetes_namespace.wordpress ]
}
