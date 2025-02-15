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
        create      = true,
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
        create      = true,
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

resource "helm_release" "aws_ebs_csi_driver" {
  name       = "aws-ebs-csi-driver"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  #version    = var.aws_load_balancer_controller_chart_version

  values = [
  yamlencode({
    clusterName = var.eks_cluster_name,
    controller = {
      serviceAccount = {
        create      = true,
        name        = "aws-ebs-csi-driver-sa",  // same as your working command
        annotations = {
          "eks.amazonaws.com/role-arn" = var.csi_driver_role_arn
        }
      }
    }
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
