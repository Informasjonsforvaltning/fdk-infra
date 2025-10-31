# Kubernetes-related Service Accounts

resource "google_service_account" "kubernetes" {
  account_id   = var.service_accounts.kubernetes
  display_name = "GKE Node Service Account"
  project      = var.project_id
}

resource "google_service_account" "flux_sa" {
  account_id   = var.service_accounts.flux
  description  = "Service account for Flux"
  display_name = "${var.project_id}-flux-sa"
  project      = var.project_id
}

resource "google_service_account" "autodeploy_sa" {
  account_id   = var.service_accounts.autodeploy
  description  = "Service account for deploying to dev environments"
  display_name = "${var.project_id}-autodeploy"
  project      = var.project_id
}

resource "google_service_account" "eso_reader_sa" {
  account_id   = var.service_accounts.eso_reader
  description  = "Service account for accessing GCP Secret Manager"
  display_name = "${var.project_id}-eso-reader-sa"
  project      = var.project_id
}

# Kubernetes Service Accounts for Workload Identity
# These service accounts are linked to Google Cloud service accounts via Workload Identity

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

# Dedicated service account for monitoring namespace cloud-sql-proxy
resource "kubernetes_service_account" "monitoring_cloud_sql_sa" {
  metadata {
    name      = var.monitoring_cloud_sql_k8s_sa_name
    namespace = var.monitoring_namespace
    annotations = {
      "iam.gke.io/gcp-service-account" = "${var.monitoring_cloud_sql_gcp_sa}@${var.project_id}.iam.gserviceaccount.com"
    }
  }
}