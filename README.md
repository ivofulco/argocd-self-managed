# argocd-self-managed
Repository to implement ArgoCD to self manage for bootstrapping environment


helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
kubectl create namespace argocd


helm install argocd argo/argo-cd -n argo-cd

kubectl -n argo-cd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d


kubectl port-forward svc/argocd-server -n argocd 8080:443
# kubectl apply -f bootstrap/.


###

ArgoCD needs policy, projects, cluster config




![alt text](image.png)


# Alteração no ArgoCD

Necessário remover o application, alterar e aplicar novamente



```
kubectl delete -f terraform/install/argocd-bootstrap.yaml
# Alterar
kubectl apply -f terraform/install/argocd-bootstrap.yaml


kubectl delete -f gitops/argo-cd/argo-cd.yaml

kubectl delete -f gitops/grafana/grafana.yaml


kubectl apply -f gitops/argo-cd/argo-cd.yaml
```