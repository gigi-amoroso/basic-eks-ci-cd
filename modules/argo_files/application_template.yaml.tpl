apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: wordpress-${env}
  namespace: argocd
spec:
  project: default
  source:
    repoURL: "https://github.com/gigi-amoroso/wordpress.git"
    targetRevision: ${env}
    path: .
    helm:
      valueFiles:
        - values.yaml
      parameters:
        - name: ingress.hostname
          value: "${domain_name}"
        - name: externalDatabase.host
          value: "${db_host}"
        - name: externalDatabase.user
          value: "${db_user}"
        - name: externalDatabase.database
          value: "${db_name}"
        - name: serviceAccount.name
          value: "${service_account_name}"
  destination:
    server: "https://kubernetes.default.svc"
    namespace: "wordpress-${env}"
  syncPolicy:
    automated:
      prune: true
      selfHeal: true