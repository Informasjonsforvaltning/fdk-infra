# Kubernetes-related Service Accounts

resource "google_service_account" "kubernetes" {
  account_id   = var.service_accounts.kubernetes
  display_name = "GKE Node Service Account"
  project      = var.project_id
}

resource "google_service_account" "autodeploy_sa" {
  account_id   = var.service_accounts.autodeploy
  description  = "Service account for deploying to prod environment"
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

# Kubernetes service account for External Secrets Operator
resource "kubernetes_service_account" "external_secrets_sa" {
  metadata {
    name      = var.eso_k8s_sa_name
    namespace = var.eso_namespace
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.eso_reader_sa.email
    }
  }
}

resource "google_service_account_iam_member" "eso_reader_workload_identity" {
  service_account_id = google_service_account.eso_reader_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.eso_namespace}/${var.eso_k8s_sa_name}]"
}

resource "google_project_iam_member" "eso_reader_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.eso_reader_sa.email}"
}

# Workload Identity bindings for the service accounts created above
resource "google_service_account_iam_member" "workload_identity_bindings" {
  for_each = toset([
    for combination in setproduct(var.k8s_namespaces, var.k8s_service_accounts) : "${combination[0]}/${combination[1]}"
  ])

  service_account_id = "projects/${var.project_id}/serviceAccounts/${var.k8s_to_gcp_service_account_mapping[split("/", each.key)[1]]}@${var.project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${each.key}]"
}

resource "google_service_account_iam_member" "monitoring_cloud_sql_workload_identity" {
  service_account_id = "projects/${var.project_id}/serviceAccounts/${var.monitoring_cloud_sql_gcp_sa}@${var.project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.monitoring_namespace}/${var.monitoring_cloud_sql_k8s_sa_name}]"
}
