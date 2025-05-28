# Adiciona o repositório Helm do Argo CD
add-argocd:
	helm repo add argo https://argoproj.github.io/argo-helm
	helm repo update

# Cria o namespace argocd após adicionar o repositório
create-ns: add-argocd
	kubectl create namespace argocd || echo "Namespace já existe"

# Instala o Argo CD via Helm
install-argo: create-ns
	helm install argocd argo/argo-cd -n argocd

# Inicializa o Terraform
i:
	terraform -chdir=terraform/install init -upgrade

# Aplica a infraestrutura com Terraform
a: i
	terraform -chdir=terraform/install apply -auto-approve

# Destroi a infraestrutura com Terraform
d:
	terraform -chdir=terraform/install destroy -auto-approve

# Pega a senha do admin inicial do Argo CD
get-secret-admin: install-argo
	kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d > secret-admin-password.txt

# Encaminha a porta local para o serviço do Argo CD
port-forward:
	kubectl port-forward svc/argocd-server -n argocd 8080:443

# Aplica o manifesto de bootstrap do Argo CD
apply-manifest:
	kubectl apply -f terraform/install/argocd-bootstrap.yaml

# Remove tudo: helm, namespace, arquivos do Terraform
destroy-all:
	helm uninstall argocd || true
	kubectl delete namespace argocd || true
	rm -rf .terraform terraform/install/.terraform terraform/install/.terraform.tfstate* terraform/install/.terraform.lock.hcl terraform/install/terraform.tfstate

# Login no ArgoCD via CLI
login-argo:
	argocd login localhost:8080 --insecure --username admin --password $$(cat secret-admin-password.txt)
