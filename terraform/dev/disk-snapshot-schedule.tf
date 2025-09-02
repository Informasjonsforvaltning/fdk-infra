resource "google_compute_resource_policy" "snapshot_daily_14_days" {
  name    = "${var.disk_prefix}-snapshot-${var.region}-daily-14-days"
  project = var.project_id
  region  = var.region

  snapshot_schedule_policy {
    retention_policy {
      max_retention_days    = 14
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
    }

    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time    = "23:00"
      }
    }

    snapshot_properties {
      storage_locations = [var.region]
    }
  }
}
