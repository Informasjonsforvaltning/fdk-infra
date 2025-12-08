# Performance Testing GKE Cluster
# Dedicated cluster for performance testing workloads

resource "google_container_cluster" "test" {
  addons_config {
    gce_persistent_disk_csi_driver_config {
      enabled = var.gke_cluster_config.addons_config.gce_persistent_disk_csi_driver_enabled
    }

    horizontal_pod_autoscaling {
      disabled = var.gke_cluster_config.addons_config.horizontal_pod_autoscaling_disabled
    }

    http_load_balancing {
      disabled = var.gke_cluster_config.addons_config.http_load_balancing_disabled
    }

    network_policy_config {
      disabled = var.gke_cluster_config.addons_config.network_policy_disabled
    }
  }

  authenticator_groups_config {
    security_group = var.gke_security_group
  }

  cluster_autoscaling {
    autoscaling_profile = var.gke_cluster_config.autoscaling_profile
  }

  database_encryption {
    state = var.gke_cluster_config.database_encryption_state
  }

  default_max_pods_per_node = var.gke_cluster_config.default_max_pods_per_node
  enable_shielded_nodes     = var.gke_cluster_config.enable_shielded_nodes

  # Create a minimal default node pool, then remove it
  # Actual node pools are managed separately in gke-node-pools.tf
  initial_node_count       = 1
  remove_default_node_pool = true

  ip_allocation_policy {
    cluster_secondary_range_name  = var.network_config.cluster_secondary_range_name
    services_secondary_range_name = var.network_config.services_secondary_range_name
    stack_type                    = "IPV4"
  }

  location = var.zone

  logging_config {
    enable_components = var.gke_cluster_config.logging_config.enable_components
  }

  maintenance_policy {
    recurring_window {
      end_time   = var.gke_cluster_config.maintenance_policy.end_time
      recurrence = var.gke_cluster_config.maintenance_policy.recurrence
      start_time = var.gke_cluster_config.maintenance_policy.start_time
    }
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  monitoring_config {
    advanced_datapath_observability_config {
      enable_metrics = var.gke_cluster_config.monitoring_config.advanced_datapath_observability_enabled
    }

    enable_components = var.gke_cluster_config.monitoring_config.enable_components
  }

  name    = var.cluster_name
  network = "projects/${var.shared_vpc_project}/global/networks/${var.shared_vpc_project}"

  network_policy {
    enabled  = var.gke_cluster_config.network_policy.enabled
    provider = var.gke_cluster_config.network_policy.provider
  }

  networking_mode = var.gke_cluster_config.networking_mode

  node_config {
    advanced_machine_features {
      threads_per_core = var.gke_cluster_config.node_config.advanced_machine_features.threads_per_core
    }

    disk_size_gb = var.gke_cluster_config.node_config.disk_size_gb
    disk_type    = var.gke_cluster_config.node_config.disk_type
    image_type   = var.gke_cluster_config.node_config.image_type

    labels = var.gke_cluster_config.node_config.labels

    logging_variant = var.gke_cluster_config.node_config.logging_variant
    machine_type    = var.gke_cluster_config.node_config.machine_type

    metadata = var.gke_cluster_config.node_config.metadata

    oauth_scopes = var.gke_cluster_config.node_config.oauth_scopes

    resource_labels = var.gke_cluster_config.node_config.resource_labels

    service_account = var.kubernetes_service_account_email

    shielded_instance_config {
      enable_integrity_monitoring = var.gke_cluster_config.node_config.shielded_instance_config.enable_integrity_monitoring
      enable_secure_boot          = var.gke_cluster_config.node_config.shielded_instance_config.enable_secure_boot
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }

  node_pool_defaults {
    node_config_defaults {
      logging_variant = var.gke_cluster_config.node_config.logging_variant
    }
  }

  private_cluster_config {
    enable_private_nodes = var.gke_cluster_config.private_cluster_config.enable_private_nodes

    master_global_access_config {
      enabled = var.gke_cluster_config.private_cluster_config.master_global_access_enabled
    }

    master_ipv4_cidr_block = var.network_config.master_ipv4_cidr_block
  }

  project = var.project_id

  release_channel {
    channel = var.gke_cluster_config.release_channel
  }

  resource_labels = var.gke_cluster_config.resource_labels

  service_external_ips_config {
    enabled = var.gke_cluster_config.service_external_ips_enabled
  }

  subnetwork = "projects/${var.shared_vpc_project}/regions/${var.region}/subnetworks/${var.network_config.subnetwork_name}"

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  lifecycle {
    ignore_changes = [
      node_config,
      node_pool
    ]
  }
}