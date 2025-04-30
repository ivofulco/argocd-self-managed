module "argocd" {
  source = "../module"
  #chart_name="argo-cd"
  #namespace="argocd"
  #repository_helm_url="https://argoproj.github.io/argo-helm"
  argocd_application_bootstrap_manifest_name = "argocd-bootstrap.yaml"
}