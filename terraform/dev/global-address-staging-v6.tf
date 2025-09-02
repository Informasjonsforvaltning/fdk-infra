resource "google_compute_global_address" "staging_v6" {
  address      = var.global_ip_addresses.staging_v6
  address_type = "EXTERNAL"
  ip_version   = "IPV6"

  labels = {
    managed-by-cnrm = "true"
  }

  name    = "${var.project_id}-staging-v6"
  project = var.project_id
}
