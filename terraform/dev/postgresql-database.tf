resource "google_sql_database_instance" "main" {
  database_version = var.database_config.database_version
  instance_type    = "CLOUD_SQL_INSTANCE"
  name             = var.database_config.instance_name
  project          = var.project_id
  region           = var.region

  settings {
    activation_policy = "ALWAYS"
    availability_type = "ZONAL"

    backup_configuration {
      backup_retention_settings {
        retained_backups = var.database_config.backup_retention_days
        retention_unit   = "COUNT"
      }

      enabled                        = true
      start_time                     = var.database_config.backup_start_time
      transaction_log_retention_days = var.database_config.backup_retention_days
    }

    connector_enforcement = "NOT_REQUIRED"
    disk_autoresize       = true
    disk_autoresize_limit = 0
    disk_type             = "PD_SSD"
    edition               = "ENTERPRISE"

    insights_config {
      query_insights_enabled = var.database_config.insights_enabled
      query_plans_per_minute = 5
      query_string_length    = 1024
    }

    ip_configuration {
      ipv4_enabled = true
      ssl_mode     = "ENCRYPTED_ONLY"
    }

    location_preference {
      zone = var.zone
    }

    maintenance_window {
      day  = var.database_config.maintenance_window.day
      hour = var.database_config.maintenance_window.hour
    }

    pricing_plan = "PER_USE"
    tier         = var.database_config.tier

    # Database flags for performance tuning
    dynamic "database_flags" {
      for_each = var.database_config.database_flags
      content {
        name  = database_flags.key
        value = database_flags.value
      }
    }

    user_labels = {
      managed-by-cnrm = "true"
    }
  }
}
