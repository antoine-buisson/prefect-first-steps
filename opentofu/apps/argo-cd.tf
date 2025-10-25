# Public Git repository
resource "argocd_repository" "personal_git" {
  repo = "https://github.com/antoine-buisson/prefect-first-steps"
}

# Git Generator - Directories
resource "argocd_application_set" "personal_git_directories" {
  metadata {
    namespace = "argo-cd"
    name      = "personal-git-directories"
  }

  spec {
    generator {
      git {
        repo_url = argocd_repository.personal_git.repo
        revision = "HEAD"

        directory {
          path = "argo-cd/*"
        }
      }
    }

    template {
      metadata {
        name = "{{path.basename}}"
      }

      spec {
        source {
          repo_url        = argocd_repository.personal_git.repo
          target_revision = "HEAD"
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