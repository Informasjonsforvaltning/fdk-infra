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

resource "kubernetes_namespace" "postgres_backup" {
  metadata {
    name = var.postgres_dump_namespace
    labels = {
      "managed-by" = "terraform"
    }
    annotations = {
      "terraform.managed"                 = "true",
      "kustomize.toolkit.fluxcd.io/prune" = "disabled"
    }
  }
}
