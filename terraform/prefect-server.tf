resource "kubernetes_namespace" "prefect-server" {
  metadata {
    name = "prefect-server"
  }
}

resource "helm_release" "prefect-server" {
  name = "prefect-server"

  repository = "https://prefecthq.github.io/prefect-helm"
  chart      = "prefect-server"
  version    = "2024.11.21014951"

  namespace = kubernetes_namespace.prefect-server.metadata[0].name
}