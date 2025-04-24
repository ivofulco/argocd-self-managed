add-argocd:
	helm repo add argo https://argoproj.github.io/argo-helm;
	helm repo update;

create-ns: add-argocd
	kubectl create namespace argocd

install-argo: create-ns
	helm install argocd argo/argo-cd -n argocd

get-secret-admin: install-argo
	kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d > secret-admin-password.txt

port-forward:
	kubectl port-forward svc/argocd-server -n argocd 8080:443

apply-manifest:
	kubectl apply -f bootstrap/.

destroy-all:
	helm uninstall argocd;
	kubectl delete namespace argocd;
	rm -rfv .terraform .terraform.tfstate* .terraform.lock.hcl terraform.tfstate;