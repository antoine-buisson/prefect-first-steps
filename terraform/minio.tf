# resource "kubernetes_namespace" "minio" {
#   metadata {
#     name = "minio"
#   }
# }

# resource "helm_release" "minio" {
#   name = "minio"

#   repository = "https://operator.min.io/"
#   chart      = "tenant"
#   version    = "6.0.4"

#   namespace = kubernetes_namespace.minio.metadata[0].name

#   values = [
#     "${file("files/minio/values.yaml")}"
#   ]
# }