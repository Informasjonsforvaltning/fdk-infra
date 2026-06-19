# Production Environment Persistent Disks
# These are existing disks that need to be imported into Terraform state
# Import command: terraform import google_compute_disk.<resource_name> projects/<project>/zones/<zone>/disks/<disk-name>

locals {
  prod_disk_labels = var.disk_labels
}

resource "google_compute_disk" "prod_cms_service" {
  labels = local.prod_disk_labels

  name                      = "${var.disk_prefix}-cms-service"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 50
  type                      = "pd-ssd"
  zone                      = var.zone
}

resource "google_compute_disk" "prod_community_service" {
  labels = local.prod_disk_labels

  name                      = "${var.disk_prefix}-community-service"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 10
  type                      = "pd-ssd"
  zone                      = var.zone
}

resource "google_compute_disk" "prod_kafka_1" {
  labels = local.prod_disk_labels

  name                      = "${var.disk_prefix}-kafka-1"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 250
  type                      = "pd-ssd"
  zone                      = var.zone
}

resource "google_compute_disk" "prod_kafka_2" {
  labels = local.prod_disk_labels

  name                      = "${var.disk_prefix}-kafka-2"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 250
  type                      = "pd-ssd"
  zone                      = var.zone
}

resource "google_compute_disk" "prod_kafka_3" {
  labels = local.prod_disk_labels

  name                      = "${var.disk_prefix}-kafka-3"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 250
  type                      = "pd-ssd"
  zone                      = var.zone
}

# Primary data disk for the prod MongoDB instance.
# GKE-provisioned and retained; imported into Terraform so it is tracked and
# protected during teardown. Labels are managed by GKE's PD provisioner.
resource "google_compute_disk" "prod_mongodb_primary" {
  name                      = "mongodb-primary"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 50
  type                      = "pd-ssd"
  zone                      = var.zone

  lifecycle {
    # snapshot is the immutable source the CSI driver provisioned from; ignored so
    # Terraform does not try to "remove" it and force-replace the retained data disk.
    ignore_changes  = [labels, snapshot]
    prevent_destroy = true
  }
}

resource "google_compute_disk" "prod_rabbitmq" {
  labels = local.prod_disk_labels

  name                      = "${var.disk_prefix}-rabbitmq"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 10
  type                      = "pd-ssd"
  zone                      = var.zone
}

resource "google_compute_disk" "prod_reports_store" {
  labels = local.prod_disk_labels

  name                      = "${var.disk_prefix}-reports-store"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 10
  type                      = "pd-ssd"
  zone                      = var.zone
}

resource "google_compute_disk" "prod_sparql" {
  labels = local.prod_disk_labels

  name                      = "${var.disk_prefix}-sparql"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 200
  type                      = "pd-standard"
  zone                      = var.zone
}

resource "google_compute_disk" "prod_static_rdf_server" {
  labels = local.prod_disk_labels

  name                      = "${var.disk_prefix}-static-rdf-server"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 10
  type                      = "pd-ssd"
  zone                      = var.zone
}

resource "google_compute_disk" "prod_zookeeper_1" {
  labels = local.prod_disk_labels

  name                      = "${var.disk_prefix}-zookeeper-1"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 10
  type                      = "pd-ssd"
  zone                      = var.zone
}