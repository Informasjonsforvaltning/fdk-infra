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

  lifecycle {
    # DNS points at these addresses, and a released IP may not be available again.
    prevent_destroy = true
  }
}

# Temporary addresses. The Gateway is built on the gateway-* entries, then takes
# the fixed `addresses` while the GKE Ingress moves to the ingress-* entries
# (removing the static-ip annotation does not release an address). Remove the
# set once the GKE Ingress is deleted.
resource "google_compute_global_address" "gateway_temporary" {
  for_each = {
    "gateway-v4" = "IPV4"
    "gateway-v6" = "IPV6"
    "ingress-v4" = "IPV4"
    "ingress-v6" = "IPV6"
  }

  address_type = "EXTERNAL"
  ip_version   = each.value
  name         = "${var.project_id}-${each.key}"
  project      = var.project_id
}
