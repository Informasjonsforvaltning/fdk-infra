# Kubernetes Namespaces
# These namespaces are managed by Terraform to prevent accidental deletion

resource "kubernetes_namespace" "staging" {
  metadata {
    name = "staging"
    labels = {
      "managed-by" = "terraform"
    }
    annotations = {
      "terraform.managed"                 = "true",
      "kustomize.toolkit.fluxcd.io/prune" = "disabled"
    }
  }
}

resource "kubernetes_namespace" "demo" {
  metadata {
    name = "demo"
    labels = {
      "managed-by" = "terraform"
    }
    annotations = {
      "terraform.managed"                 = "true",
      "kustomize.toolkit.fluxcd.io/prune" = "disabled"
    }
  }
}