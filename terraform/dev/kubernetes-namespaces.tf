# Kubernetes Namespaces

resource "kubernetes_namespace" "staging" {
  metadata {
    name = "staging"
    
    labels = {
      "kubernetes.io/metadata.name" = "staging"
      "managed-by"                  = "terraform"
    }
    
    annotations = {
      "terraform.managed" = "true"
    }
  }
}

resource "kubernetes_namespace" "demo" {
  metadata {
    name = "demo"
    
    labels = {
      "kubernetes.io/metadata.name" = "demo"
      "managed-by"                  = "terraform"
    }
    
    annotations = {
      "terraform.managed" = "true"
    }
  }
}