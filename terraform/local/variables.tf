variable "cluster_name" {
  type        = string
  description = "Name of the cluster"
  default     = "test-cluster"
}

variable "node_worker_count" {
  type        = number
  description = "Number of worker nodes to create"
  default     = 3
}

variable "argo_private_key_file" {
  type        = string
  description = "Path to the private key file"
  default     = ""
}
