# Workload Identity Federation for GitHub Actions
# This allows GitHub Actions to authenticate to Google Cloud without service account keys

# Create Workload Identity Pool for GitHub Actions
resource "google_iam_workload_identity_pool" "github_actions" {
  workload_identity_pool_id = "github-actions"
  display_name              = "GitHub Actions Pool"
  description               = "Pool for GitHub Actions CI/CD"
  disabled                  = false
}

# Create OIDC Provider for GitHub
resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_actions.workload_identity_pool_id
  workload_identity_pool_provider_id = "github"
  display_name                       = "GitHub OIDC Provider"
  description                        = "OIDC provider for GitHub Actions"
  disabled                           = false

  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.repository"       = "assertion.repository"
    "attribute.actor"            = "assertion.actor"
    "attribute.ref"              = "assertion.ref"
    "attribute.repository_owner" = "assertion.repository_owner"
  }

  attribute_condition = "assertion.repository_owner=='${var.github_organization}'"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# Service Account for Terraform CI/CD
resource "google_service_account" "terraform_sa" {
  account_id   = var.service_accounts.terraform
  display_name = "terraform-sa"
  description  = "Service account for Terraform infrastructure management via GitHub Actions"
}

# Grant necessary permissions to Terraform CI service account
resource "google_project_iam_member" "terraform_sa_editor" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.terraform_sa.email}"
}

# Grant Secret Manager access to Terraform CI service account
resource "google_project_iam_member" "terraform_sa_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.terraform_sa.email}"
}

# Grant Storage access for Terraform state bucket
resource "google_project_iam_member" "terraform_sa_storage_admin" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.terraform_sa.email}"
}

# Grant Workload Identity Pool management permissions to Terraform CI service account
resource "google_project_iam_member" "terraform_sa_workload_identity_admin" {
  project = var.project_id
  role    = "roles/iam.workloadIdentityPoolAdmin"
  member  = "serviceAccount:${google_service_account.terraform_sa.email}"
}

# Grant project IAM administration permissions to Terraform CI service account
resource "google_project_iam_member" "terraform_sa_project_iam_admin" {
  project = var.project_id
  role    = "roles/resourcemanager.projectIamAdmin"
  member  = "serviceAccount:${google_service_account.terraform_sa.email}"
}

resource "google_project_iam_member" "terraform_sa_gke_admin" {
  project = var.project_id
  role    = "roles/container.clusterAdmin"
  member  = "serviceAccount:${google_service_account.terraform_sa.email}"
}

# Allow GitHub Actions from your repository to impersonate the Terraform CI service account
resource "google_service_account_iam_member" "github_actions_terraform_sa" {
  service_account_id = google_service_account.terraform_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/${data.google_project.current.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github_actions.workload_identity_pool_id}/attribute.repository/${var.github_repository}"
}

# Optional: Additional service account for Kubernetes deployments
resource "google_service_account" "k8s_deploy_sa" {
  account_id   = var.service_accounts.k8s_deploy
  display_name = "k8s-deploy-sa"
  description  = "Service account for Kubernetes deployments via GitHub Actions"
}

# Grant GKE access to K8s deploy service account
resource "google_project_iam_member" "k8s_deploy_sa_gke_developer" {
  project = var.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.k8s_deploy_sa.email}"
}

# Allow GitHub Actions from specific repos to impersonate the K8s deploy service account
# Create separate bindings for each allowed repository
resource "google_service_account_iam_member" "github_actions_k8s_deploy_sa" {
  for_each           = toset(var.k8s_deploy_allowed_repos)
  service_account_id = google_service_account.k8s_deploy_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/${data.google_project.current.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github_actions.workload_identity_pool_id}/attribute.repository/${each.value}"
}

# Outputs for use in GitHub Actions workflows
output "workload_identity_provider" {
  description = "The Workload Identity Provider identifier for GitHub Actions"
  value       = "projects/${data.google_project.current.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github_actions.workload_identity_pool_id}/providers/${google_iam_workload_identity_pool_provider.github.workload_identity_pool_provider_id}"
}

output "terraform_sa_service_account" {
  description = "The Terraform CI service account email"
  value       = google_service_account.terraform_sa.email
}

output "k8s_deploy_sa_service_account" {
  description = "The Kubernetes deploy CI service account email"
  value       = google_service_account.k8s_deploy_sa.email
}