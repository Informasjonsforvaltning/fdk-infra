# Demo Environment Persistent Disks

locals {
  demo_disk_labels = var.disk_labels
}

resource "google_compute_disk" "demo_kafka_1" {
  labels = local.demo_disk_labels

  name                      = "${var.disk_prefix}-demo-kafka-1"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 200
  type                      = "pd-standard"
  zone                      = var.zone
}

# Primary data disk for the (decommissioning) demo MongoDB instance.
# GKE-provisioned and retained for now; imported into Terraform so it is tracked
# and protected during teardown. Labels are managed by GKE's PD provisioner.
resource "google_compute_disk" "demo_mongodb_primary" {
  name                      = "mongodb-demo-primary"
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

resource "google_compute_disk" "demo_rabbitmq" {
  labels = local.demo_disk_labels

  name                      = "${var.disk_prefix}-demo-rabbitmq"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 200
  type                      = "pd-standard"
  zone                      = var.zone
}

resource "google_compute_disk" "demo_reports_store" {
  labels = local.demo_disk_labels

  name                      = "${var.disk_prefix}-demo-reports-store"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 200
  type                      = "pd-standard"
  zone                      = var.zone
}

resource "google_compute_disk" "demo_static_rdf_server" {
  labels = local.demo_disk_labels

  name                      = "${var.disk_prefix}-demo-static-rdf-server"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 200
  type                      = "pd-standard"
  zone                      = var.zone
}

resource "google_compute_disk" "demo_sparql" {
  labels = local.demo_disk_labels

  name                      = "${var.disk_prefix}-demo-sparql"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 200
  type                      = "pd-standard"
  zone                      = var.zone
}

resource "google_compute_disk" "demo_zookeeper_1" {
  labels = local.demo_disk_labels

  name                      = "${var.disk_prefix}-demo-zookeeper-1"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 200
  type                      = "pd-standard"
  zone                      = var.zone
}