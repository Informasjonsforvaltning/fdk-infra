locals {
  # Keys map to the live address names via "${project_id}-${key}"
  # (e.g. "v4" -> digdir-fdk-prod-v4). Do NOT prefix with "prod-": that would
  # produce digdir-fdk-prod-prod-v4 and force-replace the live LB IPs.
  global_addresses = {
    "v4" = {
      address    = var.global_ip_addresses.prod_v4
      ip_version = "IPV4"
    }
    "v6" = {
      address    = var.global_ip_addresses.prod_v6
      ip_version = "IPV6"
    }
  }
}

resource "google_compute_global_address" "addresses" {
  for_each = local.global_addresses

  address      = each.value.address
  address_type = "EXTERNAL"
  ip_version   = each.value.ip_version

  labels = {
    managed-by-cnrm = "true"
  }

  name    = "${var.project_id}-${each.key}"
  project = var.project_id
}