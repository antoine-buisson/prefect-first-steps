# open-data-stack
Fully Open Source ans self hosted Data stack for personal uses

# Requirements

- Minikube
- Opentofu: https://opentofu.org/docs/intro/install/
- Terragrunt: https://terragrunt.gruntwork.io/docs/getting-started/install/

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
terragrunt apply
```

## 3. Deploy ApplicationSet (Repository)
```sh
cd ../argo-cd-applicationset
terragrunt apply
```

## 4. Access Argo CD UI
- Get the Argo CD server URL:
  - If using ingress: http://argo-cd.localtest.me
- Get the initial admin password:
```sh
kubectl -n argo-cd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

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

# Services

- To explore or debug, you can use:
```sh
kubectl get all -A
```