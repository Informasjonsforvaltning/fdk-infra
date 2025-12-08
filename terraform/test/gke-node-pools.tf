# GKE Node Pools for Performance Testing

resource "google_container_node_pool" "pools" {
  for_each = var.gke_node_pools

  cluster            = google_container_cluster.test.name
  initial_node_count = each.value.initial_node_count
  location           = var.zone
  name               = each.key
  max_pods_per_node  = each.value.max_pods_per_node
  # Only set node_count when autoscaling is disabled
  node_count     = each.value.autoscaling == null ? each.value.node_count : null
  node_locations = [var.zone]
  project        = var.project_id

  dynamic "autoscaling" {
    for_each = each.value.autoscaling != null ? [each.value.autoscaling] : []
    content {
      location_policy = autoscaling.value.location_policy
      max_node_count  = autoscaling.value.max_node_count
    }
  }

  management {
    auto_repair  = each.value.management.auto_repair
    auto_upgrade = each.value.management.auto_upgrade
  }

  network_config {
    enable_private_nodes = each.value.network_config.enable_private_nodes
    pod_range            = var.network_config.cluster_secondary_range_name
  }

  node_config {
    advanced_machine_features {
      threads_per_core = each.value.node_config.advanced_machine_features.threads_per_core
    }

    disk_size_gb    = each.value.node_config.disk_size_gb
    disk_type       = each.value.node_config.disk_type
    image_type      = each.value.node_config.image_type
    logging_variant = each.value.node_config.logging_variant
    machine_type    = each.value.node_config.machine_type

    labels = each.value.node_config.labels

    metadata = each.value.node_config.metadata

    oauth_scopes = each.value.node_config.oauth_scopes

    resource_labels = each.value.node_config.resource_labels

    service_account = var.kubernetes_service_account_email

    shielded_instance_config {
      enable_integrity_monitoring = each.value.node_config.shielded_instance_config.enable_integrity_monitoring
      enable_secure_boot          = each.value.node_config.shielded_instance_config.enable_secure_boot
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }

  queued_provisioning {
    enabled = each.value.queued_provisioning.enabled
  }

  upgrade_settings {
    max_surge = each.value.upgrade_settings.max_surge
    strategy  = each.value.upgrade_settings.strategy
  }

  lifecycle {
    ignore_changes = [
      initial_node_count,
      node_count
    ]
  }
}