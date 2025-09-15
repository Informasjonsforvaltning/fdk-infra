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

resource "google_compute_disk" "staging_mongodb_db" {
  labels = local.staging_disk_labels

  name                      = "${var.disk_prefix}-staging-mongodb-db"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 10
  snapshot                  = "https://www.googleapis.com/compute/v1/projects/${var.project_id}/global/snapshots/${var.snapshots.staging_mongodb}"
  type                      = "pd-standard"
  zone                      = var.zone
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