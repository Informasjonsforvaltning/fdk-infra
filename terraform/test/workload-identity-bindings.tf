# Workload Identity IAM Bindings
# Grant Kubernetes service accounts permission to impersonate GCP service accounts

# Create IAM bindings for each K8s SA -> GCP SA mapping
# This allows pods using the K8s SA to authenticate as the GCP SA

resource "google_service_account_iam_member" "workload_identity_bindings" {
  for_each = toset([
    for combination in setproduct(var.k8s_namespaces, var.k8s_service_accounts) : "${combination[0]}-${combination[1]}"
  ])

  service_account_id = "projects/${var.project_id}/serviceAccounts/${var.k8s_to_gcp_service_account_mapping[join("-", slice(split("-", each.key), 1, length(split("-", each.key))))]}@${var.project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${split("-", each.key)[0]}/${join("-", slice(split("-", each.key), 1, length(split("-", each.key))))}]"
}

# External Secrets Operator workload identity binding
resource "google_service_account_iam_member" "external_secrets_workload_identity" {
  service_account_id = "projects/${var.project_id}/serviceAccounts/${var.service_accounts.eso_reader}@${var.project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[external-secrets/external-secrets-sa]"
}