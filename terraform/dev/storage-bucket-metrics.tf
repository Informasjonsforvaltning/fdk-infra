resource "google_storage_bucket" "thanos_long_term_metrics" {
  force_destroy = false

  labels = {
    managed-by-cnrm = "true"
  }

  location                 = upper(var.region)
  name                     = var.storage_buckets.thanos_bucket_name
  project                  = var.project_id
  public_access_prevention = "enforced"

  soft_delete_policy {
    retention_duration_seconds = 604800
  }

  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
}
