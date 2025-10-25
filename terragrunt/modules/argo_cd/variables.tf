// Module variables for argo_cd module
variable "namespace" {
  type    = string
  default = "argo-cd"
}

variable "release_name" {
  type    = string
  default = "argo-cd"
}

variable "chart_version" {
  type    = string
  default = "9.0.5"
}

variable "values_file" {
  type    = string
  default = ""
}
