variable "cluster_name" {
  type    = string
  default = "docker-desktop"
}
variable "namespace" {
  type        = string
  default     = "argo-cd"
  description = "Namespace do cluster onde os recursos do argocd que será criada"
}
variable "release_name" {
  type        = string
  default     = "argocd"
  description = "Nome do release Helm do ArgoCD"
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




variable "kubeconfig_path" {
  type        = string
  default     = "C:\\Users\\ivo.fulco\\.kube\\config" #"~/.kube/config"
  description = "Nome do arquivo de kubeconfig"
}
variable "kubeconfig_context" {
  type        = string
  default     = "docker-desktop"
  description = "Nome do contexto do kubeconfig"
}