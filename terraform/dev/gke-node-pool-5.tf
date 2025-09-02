resource "google_container_node_pool" "pool_5" {
  autoscaling {
    location_policy = "BALANCED"
    max_node_count  = 15
  }

  cluster            = google_container_cluster.main.name
  initial_node_count = 7
  location           = var.zone

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  max_pods_per_node = 110
  name              = "pool-5"

  network_config {
    enable_private_nodes = true
    pod_ipv4_cidr_block  = var.network_config.pod_ipv4_cidr_block
    pod_range            = "${var.disk_prefix}-k8s-pods"
  }

  node_config {
    advanced_machine_features {
      threads_per_core = 0
    }

    disk_size_gb    = 100
    disk_type       = "pd-standard"
    image_type      = "COS_CONTAINERD"
    logging_variant = "DEFAULT"
    machine_type    = "n2-highmem-4"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform", "https://www.googleapis.com/auth/userinfo.email"]

    resource_labels = {
      goog-gke-node-pool-provisioning-model = "on-demand"
    }

    service_account = google_service_account.kubernetes.email

    shielded_instance_config {
      enable_integrity_monitoring = true
      enable_secure_boot          = true
    }

    workload_metadata_config {
      mode = "GKE_METADATA"

    }
  }

  node_count     = 9
  node_locations = [var.zone]
  project        = var.project_id

  queued_provisioning {
    enabled = false
  }

  upgrade_settings {
    max_surge = 1
    strategy  = "SURGE"
  }

}
