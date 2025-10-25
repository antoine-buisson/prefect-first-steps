// Module variables for argo_cd module
variable "namespace" {
  type    = string
  default = "argo-cd"
}

variable "repo_url" {
  type    = string
  default = "https://github.com/antoine-buisson/open-data-stack"
}

variable "revision" {
  type    = string
  default = "HEAD"
}

variable "directory_path" {
  type    = string
  default = "argo-cd/*"
}
