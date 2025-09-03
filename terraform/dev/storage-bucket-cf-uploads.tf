resource "google_storage_bucket" "gcf_v2_uploads" {
  cors {
    method          = ["PUT"]
    origin          = ["https://*.cloud.google.com", "https://*.corp.google.com", "https://*.corp.google.com:*", "https://*.cloud.google", "https://*.byoid.goog"]
    response_header = ["content-type"]
  }

  force_destroy = false

  labels = {
    goog-managed-by = "cloudfunctions"
    managed-by-cnrm = "true"
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }

    condition {
      age        = 1
      with_state = "ANY"
    }
  }

  location                 = upper(var.region)
  name                     = "gcf-v2-uploads-${var.storage_buckets.project_number}.${var.region}.cloudfunctions.appspot.com"
  project                  = var.project_id
  public_access_prevention = "inherited"

  soft_delete_policy {
    retention_duration_seconds = 604800
  }

  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
}
