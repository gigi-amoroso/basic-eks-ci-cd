terraform {
  required_providers {
    kubectl = { source  = "gavinbunney/kubectl", version = ">= 1.19.0" }
  }
}

locals {
  envs = {
    dev = {
      db_host     = var.rds_addresses["dev"]
      db_user     = var.db_username
      db_name     = var.dev_db_name
      domain_name = "dev-wordpress.${var.domain_name}"
      service_account_name = var.service_account_dev_word
    }
    prod = {
      db_host     = var.rds_addresses["prod"]
      db_user     = var.db_username
      db_name     = var.prod_db_name
      domain_name = "prod-wordpress.${var.domain_name}"
      service_account_name = var.service_account_prod_word
    }
  }
}

resource "local_file" "argocd_app" {
  for_each = local.envs
  content  = templatefile("${path.module}/application_template.yaml.tpl", {
    env         = each.key
    db_host     = each.value.db_host
    db_user     = each.value.db_user
    db_name     = each.value.db_name
    domain_name = each.value.domain_name
    service_account_name = each.value.service_account_name
  })
  filename = "${path.module}/generated/argocd-app-${each.key}.yaml"
}

resource "kubectl_manifest" "wordpress_app_dev" {
  yaml_body = local_file.argocd_app["dev"].content 
}

resource "kubectl_manifest" "wordpress_app_prod" {
  yaml_body = local_file.argocd_app["prod"].content
}

data "http" "prometheus_yaml" {
  url = "https://raw.githubusercontent.com/istio/istio/release-1.24/samples/addons/prometheus.yaml"
}

locals {
  manifests = split("---", data.http.prometheus_yaml.response_body)
}

resource "kubectl_manifest" "prometheus" {
  for_each = {
    for idx, manifest in local.manifests :
    idx => trim(manifest, " \n\t") if manifest != ""
  }
  yaml_body = each.value
}

