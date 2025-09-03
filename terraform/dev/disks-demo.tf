# Demo Environment Persistent Disks

locals {
  demo_disk_labels = merge(var.disk_labels, {
    goog-k8s-cluster-location = var.zone
    goog-k8s-cluster-name     = var.project_id
  })
}

resource "google_compute_disk" "demo_kafka_1" {
  labels = merge(local.demo_disk_labels, {
    goog-k8s-node-pool-name = "pool-5"
  })

  name                      = "${var.disk_prefix}-demo-kafka-1"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 200
  type                      = "pd-standard"
  zone                      = var.zone
}

resource "google_compute_disk" "demo_mongodb_db" {
  labels = merge(local.demo_disk_labels, {
    goog-k8s-node-pool-name = "pool-2"
  })

  name                      = "${var.disk_prefix}-demo-mongodb-db"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 10
  snapshot                  = "https://www.googleapis.com/compute/v1/projects/${var.project_id}/global/snapshots/${var.snapshots.demo_mongodb}"
  type                      = "pd-standard"
  zone                      = var.zone
}

resource "google_compute_disk" "demo_rabbitmq" {
  labels = merge(local.demo_disk_labels, {
    goog-k8s-node-pool-name = "pool-5"
  })

  name                      = "${var.disk_prefix}-demo-rabbitmq"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 200
  type                      = "pd-standard"
  zone                      = var.zone
}

resource "google_compute_disk" "demo_reports_store" {
  labels = merge(local.demo_disk_labels, {
    goog-k8s-node-pool-name = "pool-5"
  })

  name                      = "${var.disk_prefix}-demo-reports-store"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 200
  type                      = "pd-standard"
  zone                      = var.zone
}

resource "google_compute_disk" "demo_static_rdf_server" {
  labels = merge(local.demo_disk_labels, {
    goog-k8s-node-pool-name = "pool-2"
  })

  name                      = "${var.disk_prefix}-demo-static-rdf-server"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 200
  type                      = "pd-standard"
  zone                      = var.zone
}

resource "google_compute_disk" "demo_zookeeper_1" {
  labels = {
    goog-gke-cluster-id-base32            = "fxtnh4tztdbjn5kwvawqni24sdaxlshlylqm6iyp5wiaownidovq"
    goog-gke-node-pool-provisioning-model = "on-demand"
    goog-gke-volume                       = ""
    goog-k8s-cluster-location             = var.zone
    goog-k8s-cluster-name                 = var.project_id
    goog-k8s-node-pool-name               = "pool-5"
    managed-by-cnrm                       = "true"
    web                                   = ""
  }

  name                      = "${var.disk_prefix}-demo-zookeeper-1"
  physical_block_size_bytes = 4096
  project                   = var.project_id
  size                      = 200
  type                      = "pd-standard"
  zone                      = var.zone
}