resource "google_storage_bucket" "elasticsearch_snapshots" {
  force_destroy = false

  location                 = upper(var.region)
  name                     = var.storage_buckets.es_snapshot_bucket_name
  project                  = var.project_id
  public_access_prevention = "enforced"

  soft_delete_policy {
    retention_duration_seconds = 604800
  }

  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
}

resource "google_service_account" "es_snapshot_sa" {
  account_id   = var.service_accounts.es_snapshot
  description  = "Service account for Elasticsearch snapshots to GCS"
  display_name = "${var.project_id}-es-snapshot-sa"
  project      = var.project_id
}

# Scoped to the snapshot bucket only, not project-wide storage access.
resource "google_storage_bucket_iam_member" "es_snapshot_object_admin" {
  bucket = google_storage_bucket.elasticsearch_snapshots.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.es_snapshot_sa.email}"
}

# The bucket name is injected into the ES namespaces rather than committed to the
# repo, which is public. Sourced from the same tfvars value Terraform uses to
# create the bucket, so there is a single source of truth.
resource "kubernetes_secret" "elasticsearch_snapshots" {
  for_each = toset(var.k8s_namespaces)

  metadata {
    name      = "elasticsearch-snapshots"
    namespace = each.value
  }

  data = {
    bucket = var.storage_buckets.es_snapshot_bucket_name
  }

  type = "Opaque"
}
