# Kubernetes Service Accounts for Workload Identity
# These service accounts are linked to existing Google Cloud service accounts (managed by dev terraform)
# via Workload Identity

resource "kubernetes_service_account" "workload_identity_service_accounts" {
  for_each = toset([
    for combination in setproduct(var.k8s_namespaces, var.k8s_service_accounts) : "${combination[0]}-${combination[1]}"
  ])

  metadata {
    name      = join("-", slice(split("-", each.key), 1, length(split("-", each.key))))
    namespace = split("-", each.key)[0]
    annotations = {
      "iam.gke.io/gcp-service-account" = "${var.k8s_to_gcp_service_account_mapping[join("-", slice(split("-", each.key), 1, length(split("-", each.key))))]}@${var.project_id}.iam.gserviceaccount.com"
    }
  }
}

# External Secrets Operator service account
resource "kubernetes_service_account" "external_secrets_sa" {
  metadata {
    name      = "external-secrets-sa"
    namespace = kubernetes_namespace.external_secrets.metadata[0].name
    annotations = {
      "iam.gke.io/gcp-service-account" = "${var.service_accounts.eso_reader}@${var.project_id}.iam.gserviceaccount.com"
    }
  }
}
