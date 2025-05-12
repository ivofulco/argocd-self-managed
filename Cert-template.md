Perfeito! Abaixo está um **exemplo prático completo** de como usar o **Cert Manager com Let's Encrypt** para emitir um certificado TLS automaticamente para um serviço exposto via **Ingress** no Kubernetes.

---

## 🛠️ Pré-requisitos

* Cluster Kubernetes funcional
* Ingress Controller (ex: NGINX Ingress) instalado
* Cert Manager instalado ([guia oficial](https://cert-manager.io/docs/installation/))

---

## 1️⃣ Instalar o Cert Manager (se ainda não fez)

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
```

---

## 2️⃣ Criar o ClusterIssuer (Let's Encrypt)

Esse recurso define qual autoridade certificadora o Cert Manager vai usar. Aqui, usamos o Let's Encrypt no modo **Staging** (teste). Depois que tudo funcionar, trocamos para produção.

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    email: seu-email@dominio.com.br
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-staging
    solvers:
    - http01:
        ingress:
          class: nginx
```

> 🔁 Substitua `seu-email@dominio.com.br` pelo seu e-mail.

```bash
kubectl apply -f cluster-issuer.yaml
```

---

## 3️⃣ Criar um Ingress que solicita um certificado TLS

Exemplo de Ingress para um serviço chamado `meu-servico` que escuta na porta 80:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: meu-servico-ingress
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-staging"
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: exemplo.seudominio.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: meu-servico
            port:
              number: 80
  tls:
  - hosts:
    - exemplo.seudominio.com
    secretName: meu-certificado-tls
```

> 🌐 Você precisa apontar o DNS `exemplo.seudominio.com` para o IP público do seu Ingress Controller.

```bash
kubectl apply -f ingress.yaml
```

---

## 4️⃣ Verificar status

Verifique se o Cert Manager está criando e validando o certificado corretamente:

```bash
kubectl describe certificate meu-certificado-tls
kubectl get certificate
kubectl get challenge
```

---

## 🚀 Produção

Quando tudo funcionar com o staging, crie um `ClusterIssuer` para **produção** assim:

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    email: seu-email@dominio.com.br
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
```

E atualize a anotação do Ingress:

```yaml
annotations:
  cert-manager.io/cluster-issuer: "letsencrypt-prod"
```

---


Ótimo! Abaixo estão os arquivos YAML prontos para você usar no seu cluster Kubernetes, com base no domínio `meudominio.ivofulco.com.br` e um serviço chamado `meu-servico`.

---

## 📁 1. `cluster-issuer-staging.yaml`

ClusterIssuer usando Let's Encrypt em ambiente de testes (staging):

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    email: seu-email@ivofulco.com.br
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-staging
    solvers:
    - http01:
        ingress:
          class: nginx
```

> **Substitua o e-mail acima** pelo seu e-mail real.

---

## 📁 2. `ingress.yaml`

Ingress que solicita certificado TLS automático para o domínio `meudominio.ivofulco.com.br`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: meu-servico-ingress
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-staging"
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: meudominio.ivofulco.com.br
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: meu-servico
            port:
              number: 80
  tls:
  - hosts:
    - meudominio.ivofulco.com.br
    secretName: meu-certificado-tls
```

---

## 📁 3. (Opcional) `cluster-issuer-prod.yaml`

Depois de testar com sucesso no ambiente de staging, use esse arquivo para passar para produção (Let's Encrypt real):

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    email: seu-email@ivofulco.com.br
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
```

E atualize a anotação no `ingress.yaml` para:

```yaml
cert-manager.io/cluster-issuer: "letsencrypt-prod"
```

---

## 🚀 Etapas finais

1. **Certifique-se de que seu DNS (`meudominio.ivofulco.com.br`) está apontando corretamente** para o IP do seu Ingress Controller.
2. Aplique os manifests:

```bash
kubectl apply -f cluster-issuer-staging.yaml
kubectl apply -f ingress.yaml
```

3. Acompanhe o progresso:

```bash
kubectl get certificate
kubectl describe certificate meu-certificado-tls
kubectl get challenge
```

Perfeito! Vamos criar um serviço e deployment de exemplo para que você possa testar o Cert Manager com HTTPS no domínio `meudominio.ivofulco.com.br`.

---

## 📁 4. `meu-servico-deployment.yaml`

Esse exemplo cria:

* Um **Deployment** com uma aplicação NGINX básica.
* Um **Service** do tipo ClusterIP, que será exposto pelo Ingress.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: meu-servico
spec:
  replicas: 1
  selector:
    matchLabels:
      app: meu-servico
  template:
    metadata:
      labels:
        app: meu-servico
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: meu-servico
spec:
  selector:
    app: meu-servico
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```

---

## ✅ Como aplicar tudo

### 1. Criar o serviço e deployment

```bash
kubectl apply -f meu-servico-deployment.yaml
```

### 2. Criar o `ClusterIssuer` (staging)

```bash
kubectl apply -f cluster-issuer-staging.yaml
```

### 3. Criar o Ingress

```bash
kubectl apply -f ingress.yaml
```

### 4. Verificar se tudo funcionou

```bash
kubectl get ingress
kubectl get certificate
kubectl describe certificate meu-certificado-tls
```

Você deve conseguir acessar sua aplicação com HTTPS via:

```
https://meudominio.ivofulco.com.br
```

> Lembre-se: o domínio precisa estar corretamente configurado no DNS para apontar ao IP do seu **Ingress Controller** (geralmente LoadBalancer). 

---
Claro, vou te ajudar com prazer! Para o Cert Manager funcionar corretamente com o Let's Encrypt, o domínio **`meudominio.ivofulco.com.br`** precisa apontar para o **IP público do Ingress Controller** do seu cluster. Vamos fazer isso em etapas simples.

---

## 🔍 Etapa 1: Obter o IP público do Ingress Controller

### Se você estiver usando NGINX com tipo `LoadBalancer`:

Execute o seguinte comando:

```bash
kubectl get svc -n ingress-nginx
```

Você deve ver uma linha semelhante a esta:

```
NAME            TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                      AGE
ingress-nginx   LoadBalancer   10.0.0.100     34.201.22.123    80:31901/TCP,443:31832/TCP   3d
```

> O valor na coluna **EXTERNAL-IP** (ex: `34.201.22.123`) é o IP público que você precisa configurar no DNS.

Caso não veja `EXTERNAL-IP`, o provisionamento pode ainda estar pendente ou o cluster não suporta LoadBalancer (como clusters locais tipo Minikube). Me avise nesse caso e eu te oriento a usar uma alternativa (tipo `ngrok`, `MetalLB` ou `NodePort`).

---

## 🧭 Etapa 2: Configurar o apontamento DNS

Agora, vá até o painel de controle onde você gerencia o domínio `ivofulco.com.br` (ex: Registro.br, Cloudflare, GoDaddy, etc.) e crie um **registro DNS do tipo A**:

| Tipo | Nome (Host)  | Valor (IP)      | TTL |
| ---- | ------------ | --------------- | --- |
| A    | `meudominio` | `34.201.22.123` | 300 |

> 🔁 Substitua `34.201.22.123` pelo IP que você obteve no comando anterior.

---

## ✅ Etapa 3: Verificar se o domínio está apontando corretamente

Você pode usar um dos comandos abaixo:

### No terminal:

```bash
nslookup meudominio.ivofulco.com.br
```

Ou:

```bash
dig meudominio.ivofulco.com.br +short
```

O IP retornado **deve bater exatamente** com o IP público do seu Ingress Controller.

---

## 🚦 Quando o DNS estiver certo…

O Let's Encrypt (via Cert Manager) conseguirá validar o domínio via HTTP (porta 80) e emitir o certificado TLS com sucesso.

Se quiser, posso te ajudar a verificar o apontamento ao vivo. É só me dizer qual o IP do seu Ingress Controller atual.

Você já tem esse IP ou precisa que eu te ajude a encontrá-lo?

Excelente pergunta! Na verdade, você **não precisa instalar o Let's Encrypt diretamente** — ele é um serviço externo, e quem fala com ele dentro do Kubernetes é o **Cert Manager**. Então, o processo é:

> ✅ **Você instala o Cert Manager**
> ✅ **Configura um `ClusterIssuer` que usa o Let's Encrypt como CA (autoridade certificadora)**
> ✅ **O Cert Manager se comunica automaticamente com a API do Let's Encrypt para emitir certificados**

---

## 📦 Resumo do que precisa ser feito:

### 1. **Instale o Cert Manager**

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
```

> Isso cria os CRDs (Custom Resource Definitions) e instala os componentes no namespace `cert-manager`.

---

### 2. **Crie um `ClusterIssuer` com Let's Encrypt**

#### ➕ Para testes (ambiente de staging):

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    email: seu-email@seudominio.com
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-staging
    solvers:
    - http01:
        ingress:
          class: nginx
```

#### ➕ Para produção (certificados válidos de verdade):

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    email: seu-email@seudominio.com
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
```

```bash
kubectl apply -f cluster-issuer-prod.yaml
```

---

### 3. **Configure o Ingress para solicitar um certificado**

Adicione essas partes no seu YAML de Ingress:

```yaml
metadata:
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  tls:
  - hosts:
    - meudominio.ivofulco.com.br
    secretName: meu-certificado-tls
```

---

### 4. **Verifique se o Cert Manager está funcionando**

```bash
kubectl get certificate
kubectl describe certificate meu-certificado-tls
kubectl get challenge
```

---

## 🧠 Recapitulando:

| Etapa                  | Ferramenta/Comando                                  |
| ---------------------- | --------------------------------------------------- |
| Instalar Cert Manager  | `kubectl apply -f https://.../cert-manager.yaml`    |
| Criar ClusterIssuer    | YAML apontando para Let's Encrypt (staging ou prod) |
| Apontar domínio no DNS | Tipo A → IP público do Ingress Controller           |
| Usar Certificado       | Configurar Ingress com anotação e seção TLS         |

---

Se quiser, posso verificar passo a passo com você, ver se tudo foi aplicado corretamente e identificar onde está travando. Quer me passar os comandos que você já executou até agora?

Ótimo! Me diga, por favor:

### ✅ Quais desses passos você **já executou**?

1. **Instalou o Cert Manager?**

   * Se sim, rodou esse comando?

     ```bash
     kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
     ```

2. **Ingress Controller está instalado?**

   * Você está usando NGINX, Traefik ou outro?
   * Rodou algo como:

     ```bash
     kubectl get svc -n ingress-nginx
     ```

3. **Qual IP público do seu Ingress?**

   * Resultado do comando acima.

4. **Apontou seu domínio (`meudominio.ivofulco.com.br`) no DNS?**

   * Onde você gerencia o DNS (ex: Registro.br, Cloudflare)?
   * Já criou o registro A com o IP?

5. **Criou o ClusterIssuer do Let's Encrypt?**

   * Se sim, usou o de produção ou o de staging?

6. **Ingress está configurado com o certificado automático?**

   * Se sim, pode colar aqui o YAML?

---

Se quiser, copie e cole aqui os **comandos que já executou** ou os **YAMLs que aplicou**, e eu reviso com você para garantir que está tudo certo. Assim consigo te ajudar com mais precisão.
