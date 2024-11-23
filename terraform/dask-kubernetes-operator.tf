resource "kubernetes_namespace" "dask-kubernetes-operator" {
  metadata {
    name = "dask-kubernetes-operator"
  }
}

resource "kubernetes_namespace" "dask" {
  metadata {
    name = "dask"
  }
}

resource "helm_release" "dask-kubernetes-operator" {
  name = "dask-kubernetes-operator"

  repository = "https://helm.dask.org"
  chart      = "dask-kubernetes-operator"
  version    = "2024.9.0"

  namespace = kubernetes_namespace.dask-kubernetes-operator.metadata[0].name
}