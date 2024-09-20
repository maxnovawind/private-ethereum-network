terraform {
  required_providers {
    kind = {
      source = "tehcyx/kind"
      version = "0.6.0"
    }
  }
}

resource "kind_cluster" "default" {
    name = var.cluster_name
    wait_for_ready = true
    node_image = var.node_image
    kind_config {
      kind        = "Cluster"
      api_version = "kind.x-k8s.io/v1alpha4"

      node {
          role = "control-plane"

          kubeadm_config_patches = [
              "kind: InitConfiguration\nnodeRegistration:\n  kubeletExtraArgs:\n    node-labels: \"ingress-ready=true\"\n"
          ]

      # expose ports 30080 and 30081 to the host
      dynamic "extra_port_mappings" {
        for_each = var.extra_port_mappings
        content {
          container_port = extra_port_mappings.value
          host_port      = extra_port_mappings.value
        }
      }
    }
      dynamic "node" {
        for_each = range(var.node_worker_count)
        content {
          role = "worker"
        }
      }
  }
}