resource "kubernetes_namespace" "prod" {
  metadata {
    name = "prod"
    labels = {
      "managed-by" = "terraform"
    }
    annotations = {
      "terraform.managed"                 = "true",
      "kustomize.toolkit.fluxcd.io/prune" = "disabled"
    }
  }
}