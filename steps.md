# End-to-End Deployment: EKS, ArgoCD, and knote-js-app

This section describes the full workflow to deploy your infrastructure and application using Terraform, ArgoCD, and Helm.

---

## 0. Prerequisites

- AWS CLI configured (`aws configure`)
- `kubectl`, `helm`, and `terraform` installed
- Access to your GitHub repo: https://github.com/fred4impact/knote-js-app-chart

---

## 1. Deploy EKS Infrastructure with Terraform

```sh
cd terraform-eks
terraform init
terraform apply
```
- Approve the plan when prompted.
- After completion, update your kubeconfig:
```sh
aws eks --region <region> update-kubeconfig --name <cluster_name>
```

---

## 2. Install ArgoCD on EKS

```sh
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

---

## 3. Access ArgoCD UI

- Port-forward the ArgoCD API server:
```sh
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
- Open `http://localhost:8080` in your browser.
- Get the initial admin password:
```sh
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

---

## 4. Clone the Application Repo

```sh
git clone https://github.com/fred4impact/knote-js-app-chart.git
cd knote-js-app-chart
```

---

## 5. Deploy the App via ArgoCD

- Create an ArgoCD Application (either via UI or CLI):

**Example using kubectl:**
```yaml
# app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: knote-js-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: 'https://github.com/fred4impact/knote-js-app-chart.git'
    targetRevision: HEAD
    path: knote-js-app-chart
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```
```sh
kubectl apply -f app.yaml
```
- Or, add the app via the ArgoCD UI.

---

## 6. Monitor and Access the App

- Watch the app sync in ArgoCD UI.
- Get the service's external IP:
```sh
kubectl get svc
```
- Access your app in the browser.

---

# Deploying knote-js-app to EKS using Helm

This guide walks you through creating a Helm chart for your Node.js app (`knote-js-app`), using your Docker image `runtesting/knote-app:v2`, pushing the chart to git, and installing it on your EKS cluster.

---

## 1. Create the Helm Chart Skeleton

From your project root, run:

```sh
helm create knote-js-app-chart
```
This will create a directory `knote-js-app-chart/` with a default Helm chart structure.

---

## 2. Customize the Chart for Your App

### a. Edit `values.yaml`

Set your image and port:

```yaml
# knote-js-app-chart/values.yaml

image:
  repository: runtesting/knote-app
  pullPolicy: IfNotPresent
  tag: "v2"

service:
  type: LoadBalancer
  port: 80

containerPort: 3000  # Change this to your app's internal port if not 3000
```

### b. Edit the Deployment Template

Open `knote-js-app-chart/templates/deployment.yaml` and ensure the container port matches your app:

```yaml
        ports:
          - containerPort: {{ .Values.containerPort }}
```

---

## 3. (Optional) Clean Up Unused Templates

If you don't need things like `serviceaccount.yaml`, `hpa.yaml`, or `ingress.yaml`, you can remove or comment them out for simplicity.

---

## 4. Test Your Chart Locally

From the root of your chart directory:

```sh
helm template ./knote-js-app-chart
```

or

```sh
helm install --dry-run --debug knote-js-app ./knote-js-app-chart
```

---

## 5. Push to Git

Initialize a git repo (if not already):

```sh
cd knote-js-app-chart
git init
git add .
git commit -m "Initial Helm chart for knote-js-app"
git remote add origin <your-git-repo-url>
git push -u origin main
```

---

## 6. Install on EKS

Once your chart is in git, you can install it on your EKS cluster:

```sh
helm repo add myrepo https://github.com/fred4impact/knote-js-app-chart # if using a chart repo
helm install knote-js-app ./knote-js-app-chart
```

Or, if you have the chart locally, just use the local path.

---
aws eks --region <region> update-kubeconfig --name <cluster_name>
aws eks --region us-east-1 update-kubeconfig --name bilarn-cluster

## 7. Access Your App

Since you set the service type to `LoadBalancer`, after a few minutes, run:

```sh
kubectl get svc
```

Look for the external IP and access your app in the browser.

---

## Summary of What to Commit
- The entire `knote-js-app-chart/` directory (with your customizations). 