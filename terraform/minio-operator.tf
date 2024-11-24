# resource "kubernetes_namespace" "minio-operator" {
#   metadata {
#     name = "minio-operator"
#   }
# }

# resource "helm_release" "minio-operator" {
#   name = "minio-operator"

#   repository = "https://operator.min.io/"
#   chart      = "minio-operator"
#   version    = "4.3.7"

#   namespace = kubernetes_namespace.minio-operator.metadata[0].name
# }