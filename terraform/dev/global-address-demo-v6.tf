resource "google_compute_global_address" "demo_v6" {
  address      = var.global_ip_addresses.demo_v6
  address_type = "EXTERNAL"
  ip_version   = "IPV6"

  labels = {
    managed-by-cnrm = "true"
  }

  name    = "${var.project_id}-demo-v6"
  project = var.project_id
}
