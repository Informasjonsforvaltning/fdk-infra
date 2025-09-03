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