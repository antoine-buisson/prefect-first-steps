# Terragrunt configuration for deploying Argo CD via the argo_cd module

include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../modules/argo_cd"
}

inputs = {
  namespace     = "argo-cd"
  release_name  = "argo-cd"
  chart_version = "9.0.5"
  values_file   = "${get_terragrunt_dir()}/argo-cd-values.yaml"
}
