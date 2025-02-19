# Install the Istio base chart
resource "helm_release" "istio_base" {
  name             = "istio-base"
  namespace        = "istio-system"
  create_namespace = true
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "base"
  version          = var.istio_version  # update as needed
}

resource "helm_release" "istiod" {
  name       = "istiod"
  namespace  = "istio-system"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  version    = var.istio_version  # update as needed
  depends_on = [helm_release.istio_base]
}

resource "helm_release" "istio_ingressgateway" {
  name       = "istio-ingressgateway"
  create_namespace = true
  namespace  = "istio-ingress"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  version    = var.istio_version  # update as needed
  depends_on = [helm_release.istiod]
}

resource "helm_release" "kiali" {
  name       = "kiali"
  namespace  = "istio-system"
  repository = "https://kiali.org/helm-charts"
  chart      = "kiali-server"
  #version    = var.kiali_version
  values = [
    yamlencode({
      auth = {
        strategy = "anonymous"  # For demo purposes; consider a more secure strategy for production.
      }
      deployment = {
        view_only = true  # Set to false if you need full admin access.
      }
    })
  ]
}

resource "kubernetes_ingress_v1" "kiali_ingress" {
  metadata {
    name      = "kiali-ingress"
    namespace = "istio-system"
    annotations = {
      "alb.ingress.kubernetes.io/group.name" = "my-group"
      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
      "alb.ingress.kubernetes.io/scheme"       = "internet-facing"
      "alb.ingress.kubernetes.io/ssl-redirect"   = "443"
      "alb.ingress.kubernetes.io/target-type"    = "ip"
      "kubernetes.io/ingress.class"              = "alb"
    }
  }
  spec {
    rule {
      host = "kiali.${var.domain_name}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              # Assuming the Kiali service is named "kiali" (the same as the Helm release name)
              name = helm_release.kiali.name
              port {
                number = 20001  # Default port for Kiali; adjust if necessary.
              }
            }
          }
        }
      }
    }
  }
}