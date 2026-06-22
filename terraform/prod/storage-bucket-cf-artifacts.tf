resource "google_storage_bucket" "gcf_v2_artifacts" {
  force_destroy = false

  labels = {
    goog-managed-by = "cloudfunctions"
    managed-by-cnrm = "true"
  }

  location                 = upper(var.region)
  name                     = "gcf-v2-artifacts-${var.storage_buckets.project_number}.${var.region}.cloudfunctions.appspot.com"
  project                  = var.project_id
  public_access_prevention = "inherited"

  soft_delete_policy {
    retention_duration_seconds = 604800
  }

  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
}