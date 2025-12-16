# Persistent Disks for Performance Testing
# These disks mirror the production disk setup for realistic testing

locals {
  test_disk_labels = {
    managed-by-cnrm = "true"
    environment     = "test"
  }
}

# CMS Service disk
resource "google_compute_disk" "test_cms_service" {
  labels = local.test_disk_labels

  name                      = "${var.disk_prefix}-cms-service"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 50
  type                      = "pd-ssd"
  zone                      = var.zone
}

# Community Service disk
resource "google_compute_disk" "test_community_service" {
  labels = local.test_disk_labels

  name                      = "${var.disk_prefix}-community-service"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 10
  type                      = "pd-ssd"
  zone                      = var.zone
}

# Kafka disks (3 instances for cluster)
resource "google_compute_disk" "test_kafka_1" {
  labels = local.test_disk_labels

  name                      = "${var.disk_prefix}-kafka-1"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 200
  type                      = "pd-ssd"
  zone                      = var.zone
}

resource "google_compute_disk" "test_kafka_2" {
  labels = local.test_disk_labels

  name                      = "${var.disk_prefix}-kafka-2"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 200
  type                      = "pd-ssd"
  zone                      = var.zone
}

resource "google_compute_disk" "test_kafka_3" {
  labels = local.test_disk_labels

  name                      = "${var.disk_prefix}-kafka-3"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 200
  type                      = "pd-ssd"
  zone                      = var.zone
}

# MongoDB database disk
resource "google_compute_disk" "test_mongodb_db" {
  labels = local.test_disk_labels

  name                      = "${var.disk_prefix}-mongodb-db"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 50
  type                      = "pd-ssd"
  zone                      = var.zone
}

# RabbitMQ disk
resource "google_compute_disk" "test_rabbitmq" {
  labels = local.test_disk_labels

  name                      = "${var.disk_prefix}-rabbitmq"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 10
  type                      = "pd-ssd"
  zone                      = var.zone
}

# Reports Store disk
resource "google_compute_disk" "test_reports_store" {
  labels = local.test_disk_labels

  name                      = "${var.disk_prefix}-reports-store"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 10
  type                      = "pd-ssd"
  zone                      = var.zone
}

# SPARQL disk
resource "google_compute_disk" "test_sparql" {
  labels = local.test_disk_labels

  name                      = "${var.disk_prefix}-sparql"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 1000
  type                      = "pd-standard"
  zone                      = var.zone
}

# Static RDF Server disk
resource "google_compute_disk" "test_static_rdf_server" {
  labels = local.test_disk_labels

  name                      = "${var.disk_prefix}-static-rdf-server"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 10
  type                      = "pd-ssd"
  zone                      = var.zone
}

# Zookeeper disk
resource "google_compute_disk" "test_zookeeper_1" {
  labels = local.test_disk_labels

  name                      = "${var.disk_prefix}-zookeeper-1"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 10
  type                      = "pd-ssd"
  zone                      = var.zone
}

# MongoDB Primary disk (used by apps/test/mongodb persistent volume)
resource "google_compute_disk" "mongodb_test_primary" {
  labels = local.test_disk_labels

  name                      = "mongodb-test-primary"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 50
  type                      = "pd-ssd"
  zone                      = var.zone
}