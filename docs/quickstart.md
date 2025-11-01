# Quick Start

## 1. Start Kubernetes with Ingress
```sh
minikube start
minikube addons enable ingress
minikube tunnel
```
- Ingresses with host `*.localtest.me` will be available.

## 2. Deploy Argo CD
```sh
cd terragrunt/argo-cd
terragrunt apply -auto-approve
```

## 3. Access Argo CD UI
- Get the Argo CD server URL:
  - If using ingress: http://argo-cd.localtest.me
- Get the initial admin password:
```sh
kubectl -n argo-cd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

## 4. Deploy ApplicationSet (Repository)
*Make sure the Argo CD server URL is working*
```sh
cd ../argo-cd-applicationset
terragrunt apply -auto-approve
```

## 5. Browse the services
- Get the Argo CD server URL:
  - If using ingress: http://argo-cd.localtest.me
- Deploy Homepage
- Get the Homepage URL:
  - If using ingress: http://localtest.me

# Stopping and Cleaning Up

## Stop Kubernetes
```sh
minikube stop
```

## Delete Kubernetes
```sh
minikube delete
```

# Notes
- Make sure your kubeconfig is set up and `kubectl config use-context minikube` is run if needed.
- All Terragrunt commands should be run from the appropriate subfolder (not the root).
- If you change the namespace or other settings, update both Argo CD and ApplicationSet configs accordingly.