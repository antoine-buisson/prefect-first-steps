resource "kubernetes_namespace" "spark-operator" {
  metadata {
    name = "spark-operator"
  }
}

resource "helm_release" "spark-operator" {
  name = "spark-operator"

  repository = "https://kubeflow.github.io/spark-operator"
  chart      = "spark-operator"
  version    = "2.0.2"

  namespace = kubernetes_namespace.spark-operator.metadata[0].name
}

resource "kubernetes_service_account" "prefect-spark-operator-sa" {
  metadata {
    name      = "prefect-spark-operator-sa"
    namespace = kubernetes_namespace.prefect-worker.metadata[0].name
  }
}

resource "kubernetes_role" "sparkoperator-admin" {
  metadata {
    name      = "sparkoperator-admin"
    namespace = "default"
  }

  rule {
    api_groups = ["sparkoperator.k8s.io"]
    resources  = ["sparkapplications"]
    verbs      = ["*"]
  }
}

resource "kubernetes_role_binding" "sparkoperator-admin-binding" {
  metadata {
    name      = "sparkoperator-admin-binding"
    namespace = "default"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.sparkoperator-admin.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.prefect-spark-operator-sa.metadata[0].name
    namespace = kubernetes_service_account.prefect-spark-operator-sa.metadata[0].namespace
  }
}