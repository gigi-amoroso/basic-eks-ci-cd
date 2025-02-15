# Create the namespace for the dev environment
resource "kubernetes_namespace" "wordpress_dev" {
  metadata {
    name = "wordpress-dev"
  }
}

resource "kubernetes_service_account" "wordpress_rds_dev_sa" {
  metadata {
    name      = "wordpress-rds-dev-sa"
    namespace = "wordpress-dev"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.rds_dev_sa.iam_role_arn
    }
  }
}

# Create the namespace for the prod environment
resource "kubernetes_namespace" "wordpress_prod" {
  metadata {
    name = "wordpress-prod"
  }
}

resource "kubernetes_service_account" "wordpress_rds_prod_sa" {
  metadata {
    name      = "wordpress-rds-prod-sa"
    namespace = "wordpress-prod"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.rds_prod_sa.iam_role_arn
    }
  }
}
