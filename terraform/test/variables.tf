# Performance Testing Cluster Variables
# Simplified configuration for a dedicated performance testing environment

# Core Infrastructure Configuration
variable "project_id" {
  description = "Google Cloud project ID"
  type        = string
}

variable "region" {
  description = "Google Cloud region"
  type        = string
}

variable "zone" {
  description = "Google Cloud zone"
  type        = string
}

variable "cluster_name" {
  description = "Name of the GKE test cluster"
  type        = string
}

variable "disk_prefix" {
  description = "Prefix for disk names - kept in Secret Manager"
  type        = string
}

variable "shared_vpc_project" {
  description = "Shared VPC project ID"
  type        = string
}

variable "gke_security_group" {
  description = "GKE security group"
  type        = string
}

# Network Configuration for Test Cluster
variable "network_config" {
  description = "Network CIDR configuration for test cluster"
  type = object({
    master_ipv4_cidr_block        = string
    pod_ipv4_cidr_block           = string
    cluster_secondary_range_name  = string
    services_secondary_range_name = string
    subnetwork_name               = string
  })
}

# PostgreSQL Database Configuration
variable "database_config" {
  description = "PostgreSQL database configuration"
  type = object({
    instance_name         = string
    database_version      = string
    tier                  = string
    backup_start_time     = string
    backup_retention_days = number
    insights_enabled      = bool
    maintenance_window = object({
      day  = number
      hour = number
    })
    # Database flags for performance tuning (optional)
    database_flags = optional(map(string), {})
  })
}

# Service Account Configuration
variable "service_accounts" {
  description = "Service account names"
  type        = map(string)
}

# # Storage Bucket Configuration
# variable "storage_buckets" {
#   description = "Storage bucket configuration"
#   type = object({
#     project_number     = string
#     thanos_bucket_name = string
#   })
# }

# GKE Test Cluster Configuration
variable "gke_cluster_config" {
  description = "GKE test cluster configuration"
  type = object({
    default_max_pods_per_node = number
    enable_shielded_nodes     = bool
    autoscaling_profile       = string
    release_channel           = string
    networking_mode           = string

    maintenance_policy = object({
      start_time = string
      end_time   = string
      recurrence = string
    })

    node_config = object({
      disk_size_gb    = number
      disk_type       = string
      image_type      = string
      machine_type    = string
      logging_variant = string
      labels          = map(string)
      oauth_scopes    = list(string)

      shielded_instance_config = object({
        enable_integrity_monitoring = bool
        enable_secure_boot          = bool
      })

      advanced_machine_features = object({
        threads_per_core = number
      })

      metadata        = map(string)
      resource_labels = map(string)
    })

    addons_config = object({
      gce_persistent_disk_csi_driver_enabled = bool
      horizontal_pod_autoscaling_disabled    = bool
      http_load_balancing_disabled           = bool
      network_policy_disabled                = bool
    })

    logging_config = object({
      enable_components = list(string)
    })

    monitoring_config = object({
      enable_components                       = list(string)
      advanced_datapath_observability_enabled = bool
    })

    network_policy = object({
      enabled  = bool
      provider = string
    })

    private_cluster_config = object({
      enable_private_nodes         = bool
      master_global_access_enabled = bool
    })

    service_external_ips_enabled = bool
    database_encryption_state    = string
    resource_labels              = map(string)
  })
}

# GKE Node Pool Configurations for Performance Testing
variable "gke_node_pools" {
  description = "GKE node pool configurations for performance testing"
  type = map(object({
    initial_node_count = number
    node_count         = optional(number)
    max_pods_per_node  = number

    autoscaling = optional(object({
      location_policy = string
      max_node_count  = number
    }))

    management = object({
      auto_repair  = bool
      auto_upgrade = bool
    })

    network_config = object({
      enable_private_nodes = bool
    })

    node_config = object({
      disk_size_gb    = number
      disk_type       = string
      image_type      = string
      machine_type    = string
      logging_variant = string
      labels          = optional(map(string), {})
      oauth_scopes    = list(string)

      shielded_instance_config = object({
        enable_integrity_monitoring = bool
        enable_secure_boot          = bool
      })

      advanced_machine_features = object({
        threads_per_core = number
      })

      metadata        = map(string)
      resource_labels = map(string)
    })

    queued_provisioning = object({
      enabled = bool
    })

    upgrade_settings = object({
      max_surge = number
      strategy  = string
    })
  }))
}

# Service Account Configuration
variable "kubernetes_service_account_email" {
  description = "Email of the Kubernetes service account (shared with dev)"
  type        = string
}

variable "k8s_service_accounts" {
  description = "List of Kubernetes service accounts to create for Workload Identity - kept in Secret Manager"
  type        = list(string)
}

variable "k8s_to_gcp_service_account_mapping" {
  description = "Mapping of Kubernetes service account names to GCP service account names - kept in Secret Manager"
  type        = map(string)
}

variable "k8s_namespaces" {
  description = "List of Kubernetes namespaces to create service accounts in - kept in Secret Manager"
  type        = list(string)
}
