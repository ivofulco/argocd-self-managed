# argocd-self-managed
Repository to implement ArgoCD to self manage for bootstrapping environment


helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
kubectl create namespace argocd


helm install argocd argo/argo-cd -n argocd

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d


kubectl port-forward svc/argocd-server -n argocd 8080:443
# kubectl apply -f bootstrap/.