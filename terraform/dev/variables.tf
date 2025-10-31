# All variables are stored in Secret Manager for security
# Values are provided via terraform.tfvars (fetched from Secret Manager in CI)

# Core Infrastructure Configuration
variable "project_id" {
  description = "Google Cloud project ID - kept in Secret Manager"
  type        = string
}

variable "region" {
  description = "Google Cloud region - kept in Secret Manager"
  type        = string
}

variable "zone" {
  description = "Google Cloud zone - kept in Secret Manager"
  type        = string
}

variable "github_repository" {
  description = "GitHub repository path (org/repo) for Workload Identity Federation - kept in Secret Manager"
  type        = string
}

variable "github_organization" {
  description = "GitHub organization name for Workload Identity Federation - kept in Secret Manager"
  type        = string
}

variable "k8s_deploy_allowed_repos" {
  description = "List of repositories allowed to use k8s deploy service account - kept in Secret Manager"
  type        = list(string)
}

variable "disk_prefix" {
  description = "Prefix for disk names - kept in Secret Manager"
  type        = string
}

variable "shared_vpc_project" {
  description = "Shared VPC project ID - kept in Secret Manager"
  type        = string
}

variable "gke_security_group" {
  description = "GKE security group - kept in Secret Manager"
  type        = string
}

variable "global_ip_addresses" {
  description = "Global IP addresses for load balancers - kept in Secret Manager"
  type = object({
    demo_v4           = string
    demo_v6           = string
    staging_v4        = string
    staging_v6        = string
    staging_subnet_v4 = string
    staging_subnet_v6 = string
  })
}

# Cloud Armor Policy Names and Configurations
variable "cloud_armor_policies" {
  description = "Cloud Armor security policy names and configurations - kept in Secret Manager"
  type = map(object({
    name        = string
    preview     = optional(bool, false)
    enable_ddos = optional(bool, false)
  }))
}

# PostgreSQL Database Configuration
variable "database_config" {
  description = "PostgreSQL database configuration - kept in Secret Manager"
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
  description = "Service account names - kept in Secret Manager"
  type        = map(string)
}

# Storage Bucket Configuration
variable "storage_buckets" {
  description = "Storage bucket configuration - kept in Secret Manager"
  type = object({
    project_number     = string
    thanos_bucket_name = string
  })
}

# Network Configuration
variable "network_config" {
  description = "Network CIDR configuration - kept in Secret Manager"
  type = object({
    master_ipv4_cidr_block = string
    pod_ipv4_cidr_block    = string
  })
}

# Snapshot Configuration
variable "snapshots" {
  description = "Snapshot names for disk restoration - kept in Secret Manager"
  type = object({
    staging_mongodb           = string
    demo_mongodb              = string
    staging_strapi            = string
    staging_community_service = string
  })
}

# reCAPTCHA Configuration
variable "recaptcha_site_key" {
  description = "reCAPTCHA site key for Cloud Armor redirect - kept in Secret Manager"
  type        = string
}

# Cloud Armor WAF Expressions
variable "cloud_armor_waf_expressions" {
  description = "Pre-built WAF expressions for Cloud Armor policies - kept in Secret Manager"
  type        = map(string)
}

# Disk Configuration
variable "disk_labels" {
  description = "Common labels for all compute disks - kept in Secret Manager"
  type        = map(string)
}

# Snapshot Schedule Configuration
variable "snapshot_schedule_config" {
  description = "Snapshot schedule policy configuration - kept in Secret Manager"
  type = object({
    policy_name           = string
    max_retention_days    = number
    on_source_disk_delete = string
    days_in_cycle         = number
    start_time            = string
  })
}

# GKE Cluster Configuration
variable "gke_cluster_config" {
  description = "GKE cluster configuration - kept in Secret Manager"
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

# GKE Node Pool Configurations
variable "gke_node_pools" {
  description = "GKE node pool configurations - kept in Secret Manager"
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

variable "k8s_namespaces" {
  description = "List of Kubernetes namespaces to create service accounts in - kept in Secret Manager"
  type        = list(string)
}

variable "k8s_service_accounts" {
  description = "List of Kubernetes service accounts to create for Workload Identity - kept in Secret Manager"
  type        = list(string)
}

variable "k8s_to_gcp_service_account_mapping" {
  description = "Mapping of Kubernetes service account names to GCP service account names - kept in Secret Manager"
  type        = map(string)
}

