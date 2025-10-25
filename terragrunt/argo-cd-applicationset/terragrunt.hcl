# Terragrunt configuration for apps-configuration

include {
  path = find_in_parent_folders("root.hcl")
}

# Use dependency block instead of depends_on
# This ensures Argo CD is applied first and outputs can be referenced if needed
# (If you don't need outputs, you can omit the 'dependency' block entirely)
dependency "argo_cd" {
  config_path = "../argo-cd"
}

generate "provider_argocd" {
  path      = "provider_argocd.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "argocd" {
  server_addr = "argo-cd.localtest.me"
  username    = "admin"
  password    = "admin"
  insecure    = true
}
EOF
}

terraform {
  source = "../modules/argo_cd_applicationset"
}

inputs = {
    namespace       = dependency.argo_cd.outputs.namespace
    repo_url        = "https://github.com/antoine-buisson/open-data-stack"
    revision        = "HEAD"
    directory_path  = "argo-cd/*"
}
