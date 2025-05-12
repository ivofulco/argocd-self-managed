output "argocd_server_url" {
  description = "URL do ArgoCD server (ClusterIP, interno ao cluster)"
  value       = "http://${helm_release.argo-cd.name}-server.${var.namespace}.svc.cluster.local"
}