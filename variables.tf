variable "kubeconfig_path" {
  type        = string
  default     = "C:\\Users\\ivo.fulco\\.kube\\config" #"~/.kube/config"
  description = "Nome do arquivo de kubeconfig"
}
variable "namespace" {
  type        = string
  default     = "argocd"
  description = "Namespace do cluster onde os recursos do argocd que será criada"
}
variable "kubeconfig_context" {
  type        = string
  default     = "docker-desktop"
  description = "Nome do contexto do kubeconfig"
}