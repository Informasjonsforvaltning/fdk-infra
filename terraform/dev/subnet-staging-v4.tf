resource "google_compute_global_address" "staging_subnet_v4" {
  address      = var.global_ip_addresses.staging_subnet_v4
  address_type = "EXTERNAL"
  ip_version   = "IPV4"

  labels = {
    managed-by-cnrm = "true"
  }

  name    = "${var.project_id}-staging-subnet-v4"
  project = var.project_id
}
