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

resource "kubernetes_cluster_role" "dask-access" {
  metadata {
    name = "dask-access"
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role" "dask-access" {
  metadata {
    name      = "dask-access"
    namespace = kubernetes_namespace.dask.metadata[0].name
  }

  rule {
    api_groups = ["kubernetes.dask.org"]
    resources  = ["daskclusters"]
    verbs      = ["list", "get", "watch", "create", "update", "delete"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "dask-access-binding" {
  metadata {
    name = "dask-access-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "dask-access"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.prefect-worker-sa.metadata[0].name
    namespace = kubernetes_namespace.prefect-worker.metadata[0].name
  }
}

resource "kubernetes_role_binding" "dask-access-binding" {
  metadata {
    name      = "dask-access-binding"
    namespace = kubernetes_namespace.dask.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.dask-access.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.prefect-worker-sa.metadata[0].name
    namespace = kubernetes_namespace.prefect-worker.metadata[0].name
  }
}