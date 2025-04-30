
- [Fluxo](#fluxo)
- [Requisitos](#requisitos)
- [Passo a passo](#passo-a-passo)

# Fluxo

- [x] Terraform vai provisionar o cluster genesis
- [ ] Clusters genesis vai provisionar o ArgoCD
- [ ] ArgoCD vai se gerenciar
- [ ] ArgoCD vai gerenciar Addons:
	- [ ] CertManager
	- [ ] Istio
	- [ ] Crossplane
	- [ ] Prometheus
	- [ ] Grafana

---

# Requisitos

1. Usar helm chart online para provisionar o ArgoCD já com `Controller Sharding` habilitado
2. Repositório dividido em pastas para Applications, Bootstrap, Addons

---

# Passo a passo

1. Implementar o ArgoCD via Helm ( mesmo fluxo com Terraform) em um cluster novo sem CRD's do ArgoCD (*importante pois pode impactar a instalação*)

```bash

helm repo add argo https://argoproj.github.io/argo-helm; 

helm repo update; 

# instalar o argocd via helm com redundancia com alta disponibilidade
helm install argocd argo/argo-cd \
  --create-namespace \
  --namespace argocd \
  --set controller.replicas=1 \
  --set server.replicas=1 \
  --set repoServer.replicas=1 \
  --set redis.replicaCount=1 \
  --set controller.highAvailability=false \
  --set server.highAvailability=false \
  --set repoServer.highAvailability=false \
  --set redis.highAvailability=false \
  --set controller.replicaStrategy="RollingUpdate"


# obter senha inicial do usuario admin
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d ;


# expor o acesso ao argocd temporariamente
kubectl expose svc argocd-server -n argocd --type=LoadBalancer --name=argocd-server-lb

# obtenha o ip
kubectl get svc argocd-server-lb -n argocd

#faça o direcionamento de porta
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

2. Crie uma aplicação para conciliar o argocd e aplicar o auto gerenciamento, como o exemplo:


```bash
# partindo do principio que você está dentro das pasta deste arquivo, volte no nível raiz para aplicar o manifesto
cd ..

# aplique o manifesto para o auto gerenciamento
kubectl apply -f argocd-self-managed-app.yaml

# autentique com o cli
argocd login localhost:54828

# force a sincronia da aplicação
argocd app sync argocd-self-management
```