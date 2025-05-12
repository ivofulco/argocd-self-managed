add-argocd:
	helm repo add argo https://argoproj.github.io/argo-helm;
	helm repo update;

create-ns: add-argocd
	kubectl create namespace argocd

install-argo: create-ns
	helm install argocd argo/argo-cd -n argocd

tfa:
	terraform -chdir=terraform//install init -upgrade ; 
	terraform -chdir=terraform//install apply -auto-approve ;
tfd:	
	terraform -chdir=terraform//install destroy -auto-approve ;

get-secret-admin: install-argo
	kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d > secret-admin-password.txt

port-forward:
	kubectl port-forward svc/argocd-server -n argocd 8080:443

apply-manifest:
	kubectl apply -f terraform//install//argocd-bootstrap.yaml

destroy-all:
	helm uninstall argocd;
	kubectl delete namespace argocd;
	rm -rfv .terraform .terraform.tfstate* .terraform.lock.hcl terraform.tfstate;

login-argo:
	argocd login localhost:53763


