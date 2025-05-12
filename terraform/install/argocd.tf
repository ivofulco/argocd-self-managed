module "argo-cd" {
  source                                     = "../module"
  chart_name                                 = "argo-cd"
  namespace                                  = "argo-cd"
  repository_helm_url                        = "https://argoproj.github.io/argo-helm"
  argocd_application_bootstrap_manifest_name = "argocd-bootstrap.yaml"
}