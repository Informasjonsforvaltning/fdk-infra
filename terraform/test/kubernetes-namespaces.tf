# Kubernetes Namespace for Performance Testing

resource "kubernetes_namespace" "test" {
  metadata {
    name = "test"
    labels = {
      "managed-by" = "terraform"
      "purpose"    = "performance-testing"
    }
    annotations = {
      "terraform.managed"                 = "true"
      "kustomize.toolkit.fluxcd.io/prune" = "disabled"
    }
  }
}

# External Secrets Namespace

resource "kubernetes_namespace" "external_secrets" {
  metadata {
    name = "external-secrets"
    labels = {
      "managed-by" = "terraform"
    }
    annotations = {
      "terraform.managed"                 = "true"
      "kustomize.toolkit.fluxcd.io/prune" = "disabled"
    }
  }
}