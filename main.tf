
/*
resource "null_resource" "helm-add-argocd" {
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = "${var.kubeconfig_path}"
    }
    command = <<-EOT
        helm repo add argo https://argoproj.github.io/argo-helm;
        helm repo update;
    EOT
  }
}
*/
resource "null_resource" "helm-install-argocd" {
  #depends_on = [ null_resource.helm-add-argocd ]
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = "${var.kubeconfig_path}"
    }
    command = <<EOF
helm install argocd argo/argo-cd -n ${var.namespace} --create-namespace
    EOF
  }
}

resource "null_resource" "get-secret-admin" {
  depends_on = [null_resource.helm-install-argocd]
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = "${var.kubeconfig_path}"
    }
    command = <<EOF
kubectl -n ${var.namespace} get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d > secret-admin-password.txt
    EOF
  }
}

resource "null_resource" "apply-argocd-addons" {
  depends_on = [null_resource.helm-install-argocd]
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = "${var.kubeconfig_path}"
    }
    command = <<-EOT
kubectl apply -f argocd-addons.yaml -n ${var.namespace}
    EOT
  }
}

resource "null_resource" "apply-argocd-apps" {
  depends_on = [null_resource.helm-install-argocd]
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = "${var.kubeconfig_path}"
    }
    command = <<-EOT
kubectl apply -f argocd-apps.yaml -n ${var.namespace}
    EOT
  }
}

resource "null_resource" "apply-argocd-bootstrap" {
  depends_on = [null_resource.helm-install-argocd]
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = "${var.kubeconfig_path}"
    }
    command = <<-EOT
kubectl apply -f argocd-bootstrap.yaml -n ${var.namespace}
    EOT
  }
}

