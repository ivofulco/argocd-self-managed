# Adicionando novos clusters

Para facilitar a administração dos ArgoCD's é possível centralizar as aplicações ou até mesmos os ArgoCD's, depende da forma como será utilizado no seu ambiente.

## Possibilidades propostas

1. Arquitetura distribuída (Cada ArgoCD é independente e responsável por conciliar suas próprias aplicações) 1-1
2. Arquitetura Hub Spoke (1 ArgoCD central gerencia todas as aplicações e os ArgoCD's) 1-*
3. Melhor dos dois mundos: Arquitetura Hub Spoke distribuída (1 ArgoCD central concilia apenas os ArgoCD's e cada ArgoCD é responsável por suas próprias conciliações)

## Requisitos

- [x] ArgoCD CLI instalado
- [x] Conectividade aos clusters e arquivo .kubeconfig separado em contexts
- [x] 1 Cluster Kubernetes Origem
- [x] 1 Cluster Kubernetes Destino

## Passo a passo

```bash
# No meu exemplo feito port-forward para acesso local em ambos os clusters
argocd login localhost

argocd cluster add <CONTEXT> — server localhost

Senha do cluster 'pai'
```

## Sync Application

Para sincronizar uma aplicação basta selecionar o destino no manifesto e apontar a aplicação normalmente, exemplo de manifesto:

```yaml
apiVersion: argoproj.io/v1beta1
kind: Application
metadata:
  name: destination-k8s-guestbook
  namespace: argocd-app
spec:
  destination:
    namespace: default
    server: 'https://api.ci-<>.com:6443'
  project: default
  source:
    path: guestbook
    repoURL: 'https://github.com/argoproj/argocd-example-apps'
```