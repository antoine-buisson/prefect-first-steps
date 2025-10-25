// Module: argo_cd
// Creates the namespace and installs Argo CD via Helm. No provider blocks here — providers are injected by Terragrunt at the live layer.

resource "kubernetes_namespace" "argo_cd" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "argo_cd" {
  name       = var.release_name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version
  namespace  = kubernetes_namespace.argo_cd.metadata[0].name

  values = [
    file(var.values_file)
  ]
}

output "namespace" {
  value = var.namespace
}
