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

resource "google_compute_disk" "demo_mongodb_db" {
  labels = local.demo_disk_labels

  name                      = "${var.disk_prefix}-demo-mongodb-db"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 10
  snapshot                  = "https://www.googleapis.com/compute/v1/projects/${var.project_id}/global/snapshots/${var.snapshots.demo_mongodb}"
  type                      = "pd-standard"
  zone                      = var.zone
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

resource "google_compute_disk" "demo_zookeeper_1" {
  labels = local.demo_disk_labels

  name                      = "${var.disk_prefix}-demo-zookeeper-1"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 200
  type                      = "pd-standard"
  zone                      = var.zone
}