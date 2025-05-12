
variable "namespace" {
  type        = string
  default     = "argocd"
  description = "Namespace do cluster onde os recursos do argocd que será criada"
}
variable "chart_name" {
  type        = string
  default     = "argo-cd"
  description = "Nome do helm chart do argocd que será criada"
}
variable "repository_helm_url" {
  type        = string
  default     = "https://argoproj.github.io/argo-helm"
  description = "URL do repositório do helm chart do argocd que será criada"
}
variable "argocd_application_bootstrap_manifest_name" {
  type        = string
  description = "Nome do manifesto que aplicará o yaml do bootstrap do argocd"
}