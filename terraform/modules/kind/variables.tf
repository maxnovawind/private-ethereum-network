variable "cluster_name" {
  type        = string
  description = "Name of the cluster"
}

variable "node_worker_count" {
  type        = number
  description = "Number of worker nodes to create"
}

variable "node_image" {
  type        = string
  description = "Image to use for the nodes"
  default = "kindest/node:v1.27.1"
}

variable "extra_port_mappings" {
  type        = map(string)
  description = "Extra port mappings"
}