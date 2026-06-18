# Staging Environment Persistent Disks

locals {
  staging_disk_labels = var.disk_labels
}

resource "google_compute_disk" "staging_community_service" {
  labels = local.staging_disk_labels

  name                      = "${var.disk_prefix}-staging-community-service"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 10
  snapshot                  = "https://www.googleapis.com/compute/v1/projects/${var.project_id}/global/snapshots/${var.snapshots.staging_community_service}"
  type                      = "pd-standard"
  zone                      = var.zone
}

resource "google_compute_disk" "staging_kafka_1" {
  labels = local.staging_disk_labels

  name                      = "${var.disk_prefix}-staging-kafka-1"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 200
  type                      = "pd-standard"
  zone                      = var.zone
}

# Primary data disk for the (decommissioning) staging MongoDB instance.
# GKE-provisioned and retained for now; imported into Terraform so it is tracked
# and protected during teardown. Labels are managed by GKE's PD provisioner.
resource "google_compute_disk" "staging_mongodb_primary" {
  name                      = "mongodb-staging-primary"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 50
  type                      = "pd-standard"
  zone                      = var.zone

  lifecycle {
    # snapshot is the immutable source the CSI driver provisioned from; ignored so
    # Terraform does not try to "remove" it and force-replace the retained data disk.
    ignore_changes  = [labels, snapshot]
    prevent_destroy = true
  }
}

resource "google_compute_disk" "staging_rabbitmq" {
  labels = local.staging_disk_labels

  name                      = "${var.disk_prefix}-staging-rabbitmq"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 200
  type                      = "pd-standard"
  zone                      = var.zone
}

resource "google_compute_disk" "staging_reports_store" {
  labels = local.staging_disk_labels

  name                      = "${var.disk_prefix}-staging-reports-store"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 200
  type                      = "pd-standard"
  zone                      = var.zone
}

resource "google_compute_disk" "staging_resource_service" {
  labels = local.staging_disk_labels

  name                      = "${var.disk_prefix}-staging-resource-service"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 20
  type                      = "pd-standard"
  zone                      = var.zone
}

resource "google_compute_disk" "staging_static_rdf_server" {
  labels = local.staging_disk_labels

  name                      = "${var.disk_prefix}-staging-static-rdf-server"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 200
  type                      = "pd-standard"
  zone                      = var.zone
}

resource "google_compute_disk" "staging_strapi" {
  labels = local.staging_disk_labels

  name                      = "${var.disk_prefix}-staging-strapi"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 50
  snapshot                  = "https://www.googleapis.com/compute/v1/projects/${var.project_id}/global/snapshots/${var.snapshots.staging_strapi}"
  type                      = "pd-standard"
  zone                      = var.zone
}

resource "google_compute_disk" "staging_sparql" {
  labels = local.staging_disk_labels

  name                      = "${var.disk_prefix}-staging-sparql"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 200
  type                      = "pd-standard"
  zone                      = var.zone
}

resource "google_compute_disk" "staging_zookeeper_1" {
  labels = local.staging_disk_labels

  name                      = "${var.disk_prefix}-staging-zookeeper-1"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 200
  type                      = "pd-standard"
  zone                      = var.zone
}