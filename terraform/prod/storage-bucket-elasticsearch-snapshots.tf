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

  # Create the plan service account's read grant first. Terraform sees no
  # dependency between the two, so without this an apply could create the Secret
  # and then fail before the RoleBinding exists - which leaves every subsequent
  # plan unable to refresh the Secret, and unable to create the grant that would
  # fix it, because apply is gated on plan.
  depends_on = [kubernetes_role_binding.terraform_plan_snapshot_secret_reader]
}

# roles/viewer, which the plan service account holds, grants container.configMaps.get
# but no container.secrets.* at all, so `terraform plan` cannot refresh the Secret
# above and every plan fails once it exists. GKE evaluates IAM and Kubernetes RBAC
# in parallel, so RBAC can grant this without widening the IAM role.
#
# Deliberately scoped with resourceNames to the single Secret Terraform manages:
# get on that one name, in these namespaces only. No list, no other secret. Refresh
# reads the object by name, so get is all it needs.
resource "kubernetes_role" "terraform_plan_snapshot_secret_reader" {
  for_each = toset(var.k8s_namespaces)

  metadata {
    name      = "terraform-plan-snapshot-secret-reader"
    namespace = each.value
  }

  rule {
    api_groups     = [""]
    resources      = ["secrets"]
    resource_names = ["elasticsearch-snapshots"]
    verbs          = ["get"]
  }
}

resource "kubernetes_role_binding" "terraform_plan_snapshot_secret_reader" {
  for_each = toset(var.k8s_namespaces)

  metadata {
    name      = "terraform-plan-snapshot-secret-reader"
    namespace = each.value
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.terraform_plan_snapshot_secret_reader[each.key].metadata[0].name
  }

  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "User"
    name      = google_service_account.terraform_plan_sa.email
  }
}
