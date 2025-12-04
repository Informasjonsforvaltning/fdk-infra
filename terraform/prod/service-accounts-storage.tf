# Storage and Cloud Functions Service Accounts

resource "google_service_account" "bucket_sa" {
  account_id   = var.service_accounts.bucket
  description  = "Service account for accessing storage buckets"
  display_name = "${var.project_id}-bucket-sa"
  project      = var.project_id
}

resource "google_service_account" "cf_invoker_sa" {
  account_id   = var.service_accounts.cf_invoker
  description  = "Service account for invoking cloud functions"
  display_name = "${var.project_id}-cf-invoker"
  project      = var.project_id
}