resource "kubernetes_namespace" "dask" {
  metadata {
    name = "dask"
  }
}

resource "kubernetes_service_account" "prefect-worker-sa" {
  metadata {
    name      = "prefect-worker-sa"
    namespace = kubernetes_namespace.prefect-worker.metadata[0].name
  }
}

resource "kubernetes_role" "dask-full-access" {
  metadata {
    name      = "dask-full-access"
    namespace = kubernetes_namespace.dask.metadata[0].name
  }

  rule {
    api_groups = [""]
    resources  = ["*"]
    verbs      = ["*"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["*"]
    verbs      = ["*"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["*"]
    verbs      = ["*"]
  }

  rule {
    api_groups = ["extensions"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_role_binding" "dask-full-access-binding" {
  metadata {
    name      = "dask-full-access-binding"
    namespace = kubernetes_namespace.dask.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.dask-full-access.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.prefect-worker-sa.metadata[0].name
    namespace = kubernetes_namespace.prefect-worker.metadata[0].name
  }
}