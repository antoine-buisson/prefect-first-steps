// Module: argo_cd
// Creates the argo repository and applicationset. No provider blocks here — providers are injected by Terragrunt at the live layer.

resource "random_pet" "application_set_name" {
  length    = 2
  separator = "-"
}

resource "argocd_repository" "repository" {
  repo = var.repo_url
}

# Git Generator - Directories
resource "argocd_application_set" "application_set" {
  metadata {
    namespace = var.namespace
    name      = random_pet.application_set_name.id
  }

  spec {
    generator {
      git {
        repo_url = var.repo_url
        revision = var.revision

        directory {
          path = var.directory_path
        }
      }
    }

    template {
      metadata {
        name = "{{path.basename}}"
      }

      spec {
        source {
          repo_url        = var.repo_url
          target_revision = var.revision
          path            = "{{path}}"
        }

        destination {
          server    = "https://kubernetes.default.svc"
          namespace = "{{path.basename}}"
        }

        sync_policy {
          automated {
            prune     = true
            self_heal = true
          }
          sync_options = [
            "CreateNamespace=true"
          ]
        }
      }
    }
  }
}