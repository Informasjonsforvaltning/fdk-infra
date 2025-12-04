locals {
  global_addresses = {
    "prod-v4" = {
      address    = var.global_ip_addresses.prod_v4
      ip_version = "IPV4"
    }
    "prod-v6" = {
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