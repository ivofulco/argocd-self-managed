resource "helm_release" "argo-cd" {
  name             = "argocd"
  repository       = var.repository_helm_url
  chart            = var.chart_name
  namespace        = var.namespace
  create_namespace = true
  cleanup_on_fail  = true
  version          = null
   values = [
     yamlencode({
       fullnameOverride = "argocd"
     })
   ]
}
resource "null_resource" "output_secret_admin" {
  depends_on = [helm_release.argo-cd]
  provisioner "local-exec" {
    command = <<-EOT
        kubectl get secret argocd-initial-admin-secret --namespace ${var.namespace} -o jsonpath={.data.password} | base64 -d > argocd_secret_admin.txt
    EOT
  }
}
resource "null_resource" "create_appproject" {
  depends_on = [null_resource.output_secret_admin]
  provisioner "local-exec" {
    command = <<-EOT
        kubectl apply -f appProjects.yaml --namespace ${var.namespace}
    EOT
  }
}
resource "null_resource" "apply_manifests" {
  depends_on = [null_resource.output_secret_admin]
  provisioner "local-exec" {
    command = <<-EOT
         kubectl apply -f ${var.argocd_application_bootstrap_manifest_name} --namespace ${var.namespace}
     EOT
  }
}

resource "null_resource" "apply_manifests_addons" {
  depends_on = [null_resource.apply_manifests]
  provisioner "local-exec" {
    command = <<-EOT
         kubectl apply -f appset-argocd-addons-matrix.yaml
     EOT
  }
}
