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