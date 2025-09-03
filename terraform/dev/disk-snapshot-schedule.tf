resource "google_compute_resource_policy" "disk_backup_policy" {
  name    = var.snapshot_schedule_config.policy_name
  project = var.project_id
  region  = var.region

  snapshot_schedule_policy {
    retention_policy {
      max_retention_days    = var.snapshot_schedule_config.max_retention_days
      on_source_disk_delete = var.snapshot_schedule_config.on_source_disk_delete
    }

    schedule {
      daily_schedule {
        days_in_cycle = var.snapshot_schedule_config.days_in_cycle
        start_time    = var.snapshot_schedule_config.start_time
      }
    }

    snapshot_properties {
      storage_locations = [var.region]
    }
  }
}
