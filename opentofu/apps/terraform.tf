terraform {
  required_providers {
    argocd = {
      source  = "argoproj-labs/argocd"
      version = "7.11.2"
    }
  }
}

provider "argocd" {
  server_addr = "argo-cd.localtest.me"
  username    = "admin"
  password    = "admin"
  insecure    = true
}