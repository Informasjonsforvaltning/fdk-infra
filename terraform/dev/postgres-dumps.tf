# Logical (pg_dump) backups of the databases that hold non-regenerable data.
#
# Cloud SQL backups and PITR both restore at instance granularity: recovering one
# corrupted database means cloning the whole instance and dumping one database out
# of the clone. These per-database dumps exist so that a single catalogue can be
# restored, and so two consecutive dumps can be diffed to answer "what changed".
#
# Scope is deliberately small. 
# The bulk of the instance is derived data, so it is excluded

resource "google_storage_bucket" "postgres_dumps" {
  force_destroy = false

  location                 = upper(var.region)
  name                     = var.storage_buckets.postgres_dump_bucket_name
  project                  = var.project_id
  public_access_prevention = "enforced"

  soft_delete_policy {
    retention_duration_seconds = 604800
  }

  storage_class               = "STANDARD"
  uniform_bucket_level_access = true

  # Dumps are small enough that age-based deletion is the only tiering worth
  # having. Keep a month; the daily Cloud SQL backups cover the longer horizon.
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = var.postgres_dump_retention_days
    }
  }

  # Incomplete resumable uploads from a killed Job would otherwise accumulate
  # silently and are invisible in a normal object listing.
  lifecycle_rule {
    action {
      type = "AbortIncompleteMultipartUpload"
    }
    condition {
      age = 1
    }
  }
}

resource "google_service_account" "postgres_dump_sa" {
  account_id   = var.postgres_dump_gcp_sa
  description  = "Service account for per-database pg_dump backups to GCS"
  display_name = "${var.project_id}-postgres-dump-sa"
  project      = var.project_id
}

# Scoped to the dump bucket only, not project-wide storage access.
#
# objectAdmin rather than objectCreator: OnFailure restarts the upload in the same
# pod with the same object names, and objectCreator cannot overwrite, so a retry
# after a partial upload would 403 forever. Write-once is better served by the
# bucket's lifecycle and soft-delete policies than by withholding overwrite.
resource "google_storage_bucket_iam_member" "postgres_dump_object_admin" {
  bucket = google_storage_bucket.postgres_dumps.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.postgres_dump_sa.email}"
}

resource "kubernetes_service_account" "postgres_dump_sa" {
  metadata {
    name      = var.postgres_dump_k8s_sa_name
    namespace = kubernetes_namespace.postgres_backup.metadata[0].name
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.postgres_dump_sa.email
    }
  }
}

resource "google_service_account_iam_member" "postgres_dump_workload_identity" {
  service_account_id = google_service_account.postgres_dump_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.postgres_dump_namespace}/${var.postgres_dump_k8s_sa_name}]"
}

# A dedicated least-privilege login for the dump job
resource "random_password" "postgres_dump_user" {
  length  = 32
  special = false
}

resource "google_sql_user" "postgres_dump" {
  instance = google_sql_database_instance.main.name
  name     = var.postgres_dump_db_user
  password = random_password.postgres_dump_user.result
  project  = var.project_id
}

# Delivered into the cluster by External Secrets rather than a kubernetes_secret,
# so the credential follows the same path as every other secret here and never
# sits in Terraform-managed cluster state.
resource "google_secret_manager_secret" "postgres_dump_user" {
  project   = var.project_id
  secret_id = var.postgres_dump_secret_id

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "postgres_dump_user" {
  secret = google_secret_manager_secret.postgres_dump_user.id

  secret_data = jsonencode({
    username  = var.postgres_dump_db_user
    password  = random_password.postgres_dump_user.result
    bucket    = google_storage_bucket.postgres_dumps.name
    dump_spec = join("\n", var.postgres_dump_spec)
  })
}