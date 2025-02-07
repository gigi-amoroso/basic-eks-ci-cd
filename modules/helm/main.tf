resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = var.aws_load_balancer_controller_chart_version

  values = [
    yamlencode({
      clusterName = var.eks_cluster_name,
      serviceAccount = {
        create      = false,
        name        = "aws-load-balancer-controller-iam-service-account",
        annotations = {
          "eks.amazonaws.com/role-arn" = var.aws_load_balancer_controller_role_arn
        }
      }
    })
  ]
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  namespace  = var.external_dns_namespace
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = var.external_dns_chart_version

  values = [
    yamlencode({
      serviceAccount = {
        create      = false,
        name        = "external-dns-service-account",
        annotations = {
          "eks.amazonaws.com/role-arn" = var.external_dns_role_arn
        }
      },
      env = [
        {
          name  = "AWS_DEFAULT_REGION",
          value = var.aws_region
        }
      ]
    })
  ]
}

resource "helm_release" "aws_node_termination_handler" {
  name       = "aws-node-termination-handler"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-node-termination-handler"
  version    = var.node_termination_handler_chart_version

  values = [
    yamlencode({})
  ]
}
