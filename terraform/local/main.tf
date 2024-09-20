
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

module "kind" {
  source = "../modules/kind"

  cluster_name      = "test-cluster"
  node_worker_count = 2

  extra_port_mappings = {
    30080 = 30080
    30443 = 30443
  }
}

# helm provider
provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = module.kind.cluster_context
  }
}

# kubernetes provider
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = module.kind.cluster_context
}


module "apps" {
  source          = "../modules/apps"
  config_path     = "~/.kube/config"
  argo_chart_path = "../../helm-charts/argocd"
  argo_repo_url   = "https://github.com/maxnovawind/private-ethereum-network.git"

  argo_private_key_file = var.argo_private_key_file

  argo_chart_values_files = [
    file("../../helm-charts/argocd/values.yaml"),
    file("../../helm-charts/argocd/values.local.yaml")
  ]
  depends_on = [module.kind]
}
