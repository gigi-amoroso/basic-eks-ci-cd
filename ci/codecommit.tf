resource "aws_codecommit_repository" "wordpress_repo" {
  repository_name = "wordpress-helm-chart"
  description     = "Repository for the WordPress Helm chart (used for dev/prod deployments)"
  default_branch  = "dev"
}
