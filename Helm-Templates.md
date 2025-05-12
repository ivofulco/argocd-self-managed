### 💥 O erro `Chart.lock`

```
Error: the lock file (Chart.lock) is out of sync with the dependencies file (Chart.yaml). Please update the dependencies
```
Esse erro é bem comum e simples de resolver. O Helm está reclamando que o arquivo `Chart.lock` está **desatualizado ou inconsistente** com o que está em `Chart.yaml`.

---

### ✅ Solução: atualizar dependências e gerar o `Chart.lock`

Basta rodar o seguinte comando no diretório do chart (`grafana-wrapper`, por exemplo):

```bash
helm dependency update
```

Isso vai:

* Baixar a dependência (nesse caso, o chart do Grafana)
* Atualizar/criar o arquivo `Chart.lock`
* Criar a pasta `charts/` com o chart baixado

---

### ⚠️ Commit necessário

Se você está usando Argo CD via repositório Git, é **obrigatório que você faça commit** dos seguintes arquivos para o erro desaparecer:

✅ Commitar:

* `Chart.lock`
* a pasta `charts/` gerada

  * Ex: `charts/grafana/`
* `Chart.yaml` e `values.yaml` se tiverem sido modificados

```bash
git add Chart.lock charts/ Chart.yaml values.yaml
git commit -m "Atualiza dependências do Helm para o wrapper do Grafana"
git push
```

---

### 🧠 Por quê isso acontece?

O Argo CD não executa `helm dependency update` automaticamente. Ele espera que o chart já esteja com as dependências **resolvidas no Git**. Por isso, se faltar `Chart.lock` ou a pasta `charts/`, ou se estiverem desatualizados, ele falha ao renderizar os manifests.

---

### ✅ Recapitulando

1. Vá até a pasta do wrapper chart (ex: `gitops/grafana/`)

2. Rode:

   ```bash
   helm dependency update
   ```

3. Faça commit dos arquivos gerados:

   * `Chart.lock`
   * pasta `charts/`

4. Faça `push` para o repositório Git

5. O Argo CD deve sincronizar corretamente

---
