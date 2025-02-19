resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = var.aws_load_balancer_controller_chart_version

  values = [
    yamlencode({
      clusterName    = var.eks_cluster_name,
      serviceAccount = {
        create      = true,
        name        = "aws-load-balancer-controller-iam-service-account",
        annotations = {
          "eks.amazonaws.com/role-arn" = var.iam_role_arns["lb_controller"]
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
          "eks.amazonaws.com/role-arn" = var.iam_role_arns["external_dns"]
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

resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  create_namespace = true
  version = "7.8.2"
  depends_on = [helm_release.istiod]
  values = [
    yamlencode({
      server = {
        ingress = {
          enabled            = true,
          hostname           = "argo.${var.hostname}",
          tls                = true,          # enable TLS (boolean, not a list)
          # You can optionally set certificateSecret if you manage your own secret, 
          # but if you're using ALB's ACM certificate via annotation, it may not be needed.
          annotations = {
            "kubernetes.io/ingress.class"                 = "alb",
            "alb.ingress.kubernetes.io/group.name"          = "my-group",
            "alb.ingress.kubernetes.io/scheme"              = "internet-facing",
            "alb.ingress.kubernetes.io/ssl-redirect"        = "443",
            "alb.ingress.kubernetes.io/listen-ports"        = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]",
            "alb.ingress.kubernetes.io/target-type"         = "ip",
            "alb.ingress.kubernetes.io/certificate-arn"     = var.certificate_arn
          }
        }
      },
      configs = {
        params = {
          "server.insecure" = true
        }
      }
    })
  ]
}

resource "helm_release" "aws_ebs_csi_driver" {
  name       = "aws-ebs-csi-driver"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"

  values = [
    yamlencode({
      clusterName  = var.eks_cluster_name,
      controller = {
        serviceAccount = {
          create      = true,
          name        = "aws-ebs-csi-driver-sa",
          annotations = {
            "eks.amazonaws.com/role-arn" = var.iam_role_arns["csi_driver"]
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

output "argocd_release_id" {
  description = "The ID of the ArgoCD Helm release"
  value       = helm_release.argocd.id
}