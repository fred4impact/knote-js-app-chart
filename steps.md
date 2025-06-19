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
helm repo add myrepo <your-helm-repo-url> # if using a chart repo
helm install knote-js-app ./knote-js-app-chart
```

Or, if you have the chart locally, just use the local path.

---

## 7. Access Your App

Since you set the service type to `LoadBalancer`, after a few minutes, run:

```sh
kubectl get svc
```

Look for the external IP and access your app in the browser.

---

## Summary of What to Commit
- The entire `knote-js-app-chart/` directory (with your customizations). 