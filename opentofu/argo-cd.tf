resource "kubernetes_namespace" "argo-cd" {
  metadata {
    name = "argo-cd"
  }
}

resource "helm_release" "argo-cd" {
  name = "argo-cd"

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "9.0.5"

  namespace = kubernetes_namespace.argo-cd.metadata[0].name

  values = [
    "${file("files/argo-cd/values.yaml")}"
  ]
}

resource "kubernetes_manifest" "application-set-local" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "ApplicationSet"

    metadata = {
      namespace = kubernetes_namespace.argo-cd.metadata[0].name
      name      = "local"
    }

    spec = {
      goTemplate = true
      goTemplateOptions = [
        "missingkey=error"
      ]
      generators = [
        {
          git = {
            repoURL  = "https://github.com/antoine-buisson/prefect-first-steps"
            revision = "HEAD"
            directories = [
              {
                path = "argo-cd/*"
              }
            ]
          }
        }
      ]
      template = {
        metadata = {
          name = "{{.path.basename}}"
        }
        spec = {
          project = "default"
          source = {
            repoURL        = "https://github.com/antoine-buisson/prefect-first-steps"
            targetRevision = "HEAD"
            path           = "{{.path.path}}"
          }

          destination = {
            server    = "https://kubernetes.default.svc"
            namespace = "{{.path.basename}}"
          }
          syncPolicy = {
            automated = {
              prune    = true
              selfHeal = true
              enabled  = true
            }
            syncOptions = [
              "createNamespace=true"
            ]
          }
        }
      }
    }
  }
}