terraform {
  required_providers {
    argocd = {
      source  = "oboukili/argocd"
      version = "6.1.1"
    }
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "kubernetes_secret" "private_repo" {
  count = var.argo_private_key_file != "" ? 1 : 0
  metadata {
    name      = "private-repo"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type          = "git"
    url           = var.argo_repo_url
    sshPrivateKey = file("${var.argo_private_key_file}")
  }
  depends_on = [kubernetes_namespace.argocd]
}

resource "helm_release" "argocd" {
  name              = "argocd"
  chart             = var.argo_chart_path
  namespace         = "argocd"
  dependency_update = true
  create_namespace  = false
  values            = var.argo_chart_values_files
  depends_on        = [kubernetes_secret.private_repo]
}
