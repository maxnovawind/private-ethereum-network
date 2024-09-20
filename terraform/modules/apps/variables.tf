

variable "config_path" {
  type        = string
  description = "Path to the kubeconfig file"
}

variable "argo_repo_url" {
  type        = string
  description = "URL of the repository"
}

variable "argo_private_key_file" {
  type        = string
  description = "Path to the private key file"
  default     = ""
}

variable "argo_chart_path" {
  type        = string
  description = "Path to the chart file"
}

variable "argo_chart_values_files" {
  type        = list(string)
  description = "Path to the values file"
}






