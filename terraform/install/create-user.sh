#!/bin/bash

# Nome do usuário que será adicionado
USUARIO="my-user"

# Nome do ConfigMap e namespace
CONFIGMAP="argocd-cm"
NAMESPACE="argocd"

# Obtem o ConfigMap atual em YAML
kubectl get configmap $CONFIGMAP -n $NAMESPACE -o yaml > argocd-cm.yaml

# Verifica se a linha já existe
if grep -q "accounts.$USUARIO:" argocd-cm.yaml; then
  # Atualiza a linha existente
  sed -i "s/accounts.$USUARIO:.*/accounts.$USUARIO: login/" argocd-cm.yaml
else
  # Insere a nova linha em 'data:'
  awk -v user="accounts.$USUARIO: login" '
    BEGIN {added=0}
    /data:/ {
      print
      if (!added) {
        print "  " user
        added=1
      }
      next
    }
    {print}
  ' argocd-cm.yaml > argocd-cm-patched.yaml
  mv argocd-cm-patched.yaml argocd-cm.yaml
fi

# Aplica novamente o ConfigMap
kubectl apply -f argocd-cm.yaml

# Limpa o arquivo temporário
rm -f argocd-cm.yaml

echo "Conta '$USUARIO' adicionada ao ConfigMap '$CONFIGMAP'."
