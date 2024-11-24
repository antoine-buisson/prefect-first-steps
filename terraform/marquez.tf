resource "kubernetes_namespace" "marquez" {
  metadata {
    name = "marquez"
  }
}

resource "helm_release" "marquez" {
  name = "marquez"

  chart = "./local_charts/marquez"

  dependency_update = true

  namespace = kubernetes_namespace.marquez.metadata[0].name
}