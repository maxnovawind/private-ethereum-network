output "cluster_context" {
  value = jsondecode(jsonencode(yamldecode(kind_cluster.default.kubeconfig).contexts))[0].name
}