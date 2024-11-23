resource "kubernetes_namespace" "prefect-worker" {
  metadata {
    name = "prefect-worker"
  }
}

resource "helm_release" "prefect-worker" {
  name = "prefect-worker"

  repository = "https://prefecthq.github.io/prefect-helm"
  chart      = "prefect-worker"
  version    = "2024.11.21014951"

  namespace = kubernetes_namespace.prefect-worker.metadata[0].name

  values = [
    "${file("files/prefect-worker/values.yaml")}"
  ]

  depends_on = [kubernetes_config_map.base-job-template]
}

resource "kubernetes_config_map" "base-job-template" {
  metadata {
    namespace = kubernetes_namespace.prefect-worker.metadata[0].name
    name      = "base-job-template"
  }

  data = {
    "baseJobTemplate.json" = "${file("files/prefect-worker/baseJobTemplate.json")}"
  }
}