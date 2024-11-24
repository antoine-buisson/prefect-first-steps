resource "kubernetes_namespace" "spark" {
  metadata {
    name = "spark"
  }
}

resource "kubernetes_service_account" "dask-worker-sa" {
  metadata {
    name      = "dask-worker-sa"
    namespace = kubernetes_namespace.dask.metadata[0].name
  }
}

resource "kubernetes_role" "spark-access" {
  metadata {
    name      = "spark-access"
    namespace = kubernetes_namespace.spark.metadata[0].name
  }

  rule {
    api_groups = [""]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_role_binding" "spark-access-binding" {
  metadata {
    name      = "spark-access-binding"
    namespace = kubernetes_namespace.spark.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.spark-access.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.dask-worker-sa.metadata[0].name
    namespace = kubernetes_namespace.dask.metadata[0].name
  }
}