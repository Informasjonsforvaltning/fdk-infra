# Production Environment Persistent Disks
# These are existing disks that need to be imported into Terraform state
# Import command: terraform import google_compute_disk.<resource_name> projects/<project>/zones/<zone>/disks/<disk-name>

locals {
  prod_disk_labels = var.disk_labels
}

resource "google_compute_disk" "prod_cms_service" {
  labels = local.prod_disk_labels

  name                      = "${var.disk_prefix}-prod-cms-service"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 50
  type                      = "pd-ssd"
  zone                      = var.zone
}

resource "google_compute_disk" "prod_community_service" {
  labels = local.prod_disk_labels

  name                      = "${var.disk_prefix}-prod-community-service"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 10
  type                      = "pd-ssd"
  zone                      = var.zone
}

resource "google_compute_disk" "prod_kafka_1" {
  labels = local.prod_disk_labels

  name                      = "${var.disk_prefix}-prod-kafka-1"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 200
  type                      = "pd-ssd"
  zone                      = var.zone
}

resource "google_compute_disk" "prod_kafka_2" {
  labels = local.prod_disk_labels

  name                      = "${var.disk_prefix}-prod-kafka-2"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 200
  type                      = "pd-ssd"
  zone                      = var.zone
}

resource "google_compute_disk" "prod_kafka_3" {
  labels = local.prod_disk_labels

  name                      = "${var.disk_prefix}-prod-kafka-3"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 200
  type                      = "pd-ssd"
  zone                      = var.zone
}

resource "google_compute_disk" "prod_mongodb_db" {
  labels = local.prod_disk_labels

  name                      = "${var.disk_prefix}-prod-mongodb-db"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 200
  type                      = "pd-ssd"
  zone                      = var.zone
}

resource "google_compute_disk" "prod_rabbitmq" {
  labels = local.prod_disk_labels

  name                      = "${var.disk_prefix}-prod-rabbitmq"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 10
  type                      = "pd-ssd"
  zone                      = var.zone
}

resource "google_compute_disk" "prod_reports_store" {
  labels = local.prod_disk_labels

  name                      = "${var.disk_prefix}-prod-reports-store"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 10
  type                      = "pd-ssd"
  zone                      = var.zone
}

resource "google_compute_disk" "prod_sparql" {
  labels = local.prod_disk_labels

  name                      = "${var.disk_prefix}-prod-sparql"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 200
  type                      = "pd-standard"
  zone                      = var.zone
}

resource "google_compute_disk" "prod_static_rdf_server" {
  labels = local.prod_disk_labels

  name                      = "${var.disk_prefix}-prod-static-rdf-server"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 10
  type                      = "pd-ssd"
  zone                      = var.zone
}

resource "google_compute_disk" "prod_zookeeper_1" {
  labels = local.prod_disk_labels

  name                      = "${var.disk_prefix}-prod-zookeeper-1"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 10
  type                      = "pd-ssd"
  zone                      = var.zone
}