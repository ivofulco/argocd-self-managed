To create a **central Argo CD** setup with **Crossplane** that can provision additional **EKS clusters** and automatically connect them to the central Argo CD, you’ll need to orchestrate several components. Here’s a step-by-step guide to achieve this:

---

### 🧩 Key Components

* **Argo CD (Central)**: Deployed in a main cluster, used to manage applications across clusters.
* **Crossplane**: For provisioning AWS infrastructure, including EKS clusters.
* **EKS Clusters**: Dynamically created clusters managed by Argo CD.
* **Argo CD Cluster Secrets**: Central Argo CD must know about newly created clusters via kubeconfig secrets.

---

## ✅ Prerequisites

* Argo CD deployed in a “management” Kubernetes cluster.
* Crossplane installed in the same management cluster.
* AWS credentials configured for Crossplane.
* Git repository structure for Argo CD App of Apps pattern (optional but recommended).

---

## 🛠️ Step-by-Step Setup

---

### 1. **Install Crossplane in Argo CD Central Cluster**

```bash
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm install crossplane crossplane-stable/crossplane --namespace crossplane-system --create-namespace
```

---

### 2. **Install AWS Provider for Crossplane**

```bash
kubectl crossplane install provider crossplane/provider-aws
```

Then configure AWS credentials:

```yaml
# provider-config.yaml
apiVersion: aws.crossplane.io/v1beta1
kind: ProviderConfig
metadata:
  name: aws-provider
spec:
  credentials:
    source: Secret
    secretRef:
      namespace: crossplane-system
      name: aws-creds
      key: creds
```

---

### 3. **Provision an EKS Cluster with Crossplane**

Here’s a simplified `CompositeResourceDefinition` (XRD) or `Composition`, or you can directly apply a `Claim` and `Managed Resource`.

Example:

```yaml
apiVersion: eks.aws.crossplane.io/v1beta1
kind: Cluster
metadata:
  name: eks-cluster-demo
spec:
  forProvider:
    region: us-west-2
    roleArn: arn:aws:iam::123456789012:role/eks-cluster-role
    vpcConfig:
      subnetIds:
        - subnet-xxxxxx
        - subnet-yyyyyy
  writeConnectionSecretToRef:
    name: eks-cluster-demo-kubeconfig
    namespace: crossplane-system
  providerConfigRef:
    name: aws-provider
```

> 📦 When this finishes, Crossplane will output a `Secret` with kubeconfig under `crossplane-system`.

---

### 4. **Connect the New EKS Cluster to Argo CD**

Argo CD connects to external clusters via **cluster secrets**.

Convert the kubeconfig in the secret (`eks-cluster-demo-kubeconfig`) to an Argo CD cluster secret:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: cluster-eks-cluster-demo
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: cluster
type: Opaque
data:
  name: ZWtzLWNsdXN0ZXItZGVtbw==  # base64 of "eks-cluster-demo"
  server: aHR0cHM6Ly8xMjMuMTIzLjEyMy4xMjM=  # base64 of your cluster endpoint
  config: <base64 kubeconfig json>
```

You can write a Kubernetes Job or Argo Workflow to automate this transformation.

---

### 5. **Manage Applications on New EKS Cluster via Argo CD**

Once the new cluster is registered in Argo CD, you can deploy workloads using either:

* Argo CD App-of-Apps pointing to the new cluster.
* Argo CD Application CR with `destination.server` set to the new EKS API endpoint.

Example:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app-on-new-eks
spec:
  project: default
  source:
    repoURL: https://github.com/your-org/your-repo.git
    targetRevision: HEAD
    path: apps/my-app
  destination:
    server: https://123.123.123.123  # EKS cluster endpoint
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

---

### ✅ Optional Automation Ideas

* **Argo Workflows or Tekton Pipelines** to automate:

  * Creating cluster with Crossplane.
  * Reading the kubeconfig secret.
  * Creating the Argo CD cluster secret.
  * Deploying the Application CR.

---

## 📌 Summary

| Step | Tool            | Purpose                       |
| ---- | --------------- | ----------------------------- |
| 1    | Argo CD         | Centralized GitOps management |
| 2    | Crossplane      | Infrastructure provisioning   |
| 3    | EKS Cluster     | Provisioned dynamically       |
| 4    | Secret Creation | Register cluster in Argo CD   |
| 5    | Argo CD App     | Deploy to new cluster         |

---

If you want a complete YAML pipeline, GitOps structure, or Terraform + Crossplane hybrid example, I can generate that too. Just let me know your preference.


---

Here's a **Kubernetes Job** and an **Argo Workflow** example that automates **Step 4**: transforming the Crossplane-generated kubeconfig Secret into an **Argo CD cluster registration Secret**.

---

## 🚀 Option 1: Kubernetes Job

This job:

1. Reads the kubeconfig from the Crossplane output secret.
2. Extracts the cluster endpoint.
3. Generates an Argo CD-compatible secret.

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: register-eks-to-argocd
  namespace: crossplane-system  # or a namespace with proper access
spec:
  template:
    spec:
      containers:
      - name: register
        image: bitnami/kubectl:latest
        command:
        - /bin/sh
        - -c
        - |
          set -e
          SECRET_NAME=eks-cluster-demo-kubeconfig
          KUBECONFIG_DATA=$(kubectl get secret $SECRET_NAME -n crossplane-system -o jsonpath='{.data.kubeconfig}' | base64 -d)
          SERVER=$(echo "$KUBECONFIG_DATA" | yq e '.clusters[0].cluster.server' -)
          CLUSTER_NAME=eks-cluster-demo

          kubectl create secret generic cluster-${CLUSTER_NAME} \
            -n argocd \
            --from-literal=name=$CLUSTER_NAME \
            --from-literal=server=$SERVER \
            --from-literal=config="$(echo "$KUBECONFIG_DATA" | base64)" \
            --dry-run=client -o yaml | \
            kubectl label --local -f - \
              'argocd.argoproj.io/secret-type=cluster' \
              -o yaml | \
            kubectl apply -f -
        env:
        - name: KUBECONFIG
          value: /kubeconfig/config
        volumeMounts:
        - name: kubeconfig
          mountPath: /kubeconfig
      restartPolicy: OnFailure
      volumes:
      - name: kubeconfig
        emptyDir: {}
```

> **Requirements**: `yq` must be installed in the container or replace with `jq` if you transform via `kubectl get`.

---

## 🚀 Option 2: Argo Workflow

This Argo Workflow does the same as above, using a container step.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  name: register-eks-cluster
  namespace: argo
spec:
  entrypoint: main
  templates:
  - name: main
    script:
      image: alpine:latest
      command: [sh]
      source: |
        apk add --no-cache curl bash jq yq kubectl
        SECRET_NAME=eks-cluster-demo-kubeconfig
        KUBECONFIG_DATA=$(kubectl get secret $SECRET_NAME -n crossplane-system -o jsonpath='{.data.kubeconfig}' | base64 -d)
        SERVER=$(echo "$KUBECONFIG_DATA" | yq e '.clusters[0].cluster.server' -)
        CLUSTER_NAME=eks-cluster-demo

        cat <<EOF | kubectl apply -f -
        apiVersion: v1
        kind: Secret
        metadata:
          name: cluster-${CLUSTER_NAME}
          namespace: argocd
          labels:
            argocd.argoproj.io/secret-type: cluster
        type: Opaque
        data:
          name: $(echo -n $CLUSTER_NAME | base64)
          server: $(echo -n $SERVER | base64)
          config: $(echo "$KUBECONFIG_DATA" | base64)
        EOF
```

> You can parameterize the workflow using `inputs.parameters`.

---

### 🔐 Permissions Note

Make sure the service account running either the Job or Argo Workflow has these RBAC permissions:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: cluster-reg-role
  namespace: crossplane-system
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "create", "patch", "apply"]
```

And bind it:

```yaml
kind: RoleBinding
metadata:
  name: cluster-reg-rolebinding
  namespace: crossplane-system
roleRef:
  kind: Role
  name: cluster-reg-role
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: ServiceAccount
  name: default  # or custom
  namespace: crossplane-system
```

---

Would you like this as part of a **GitOps repo structure** or deployed via Argo CD itself? I can help bootstrap that too.
