# Compute and Data Service Accounts

resource "google_service_account" "cloudsql_sa" {
  account_id   = var.service_accounts.cloudsql
  description  = "Service account for managed postgreSQL"
  display_name = "${var.project_id}-cloudsql"
  project      = var.project_id
}

resource "google_service_account" "vertex_sa" {
  account_id   = var.service_accounts.vertex_ai
  description  = "Service account for Vertex services"
  display_name = "${var.project_id}-vertex-sa"
  project      = var.project_id
}

resource "google_service_account" "error_sa" {
  account_id   = var.service_accounts.error_handler
  description  = "Service account for pushing error messages to Error reporting"
  display_name = "${var.project_id}-error-sa"
  project      = var.project_id
}