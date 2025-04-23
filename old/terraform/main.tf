terraform {
  required_version = ">= 1.0"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.7"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}
provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
}

/*
provider "helm" {
  kubernetes {
    host                   = try(data.kubernetes_host, "")
    cluster_ca_certificate = try(base64decode(data.cluster_ca_certificate), "")
    token                  = try(data.token, "")
  }
}
*/

data "github_repository_file" "argocd" {
  repository = "ivofulco/argocd-self-managed"
  branch     = "main"
  file       = "terraform/config/argo-cd-values.yaml"
}

data "github_repository_file" "argocd_apps" {
  repository = "ivofulco/argocd-self-managed"
  branch     = "main"
  file       = "terraform/config/argocd-apps-values.yaml"
}



resource "helm_release" "argocd" {
  chart            = "argo-cd"
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  #version          = "5.28.1"
  force_update     = true

  values = [
    data.github_repository_file.argocd.content
  ]

  lifecycle {
    ignore_changes = all
  }
}

resource "helm_release" "argocd_apps" {
  chart            = "argocd-apps"
  name             = "argocd-apps"
  namespace        = "argocd"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  #version          = "0.0.9"
  force_update     = true

  values = [
    data.github_repository_file.argocd_apps.content
  ]

  depends_on = [
    helm_release.argocd,
  ]

  lifecycle {
    ignore_changes = all
  }
}