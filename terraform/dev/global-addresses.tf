# Global IP Addresses - Consolidated Configuration

locals {
  # Map global IP addresses to their configurations
  global_addresses = {
    "demo-v4" = {
      address    = var.global_ip_addresses.demo_v4
      ip_version = "IPV4"
    }
    "demo-v6" = {
      address    = var.global_ip_addresses.demo_v6
      ip_version = "IPV6"
    }
    "staging-v4" = {
      address    = var.global_ip_addresses.staging_v4
      ip_version = "IPV4"
    }
    "staging-v6" = {
      address    = var.global_ip_addresses.staging_v6
      ip_version = "IPV6"
    }
    "staging-subnet-v4" = {
      address    = var.global_ip_addresses.staging_subnet_v4
      ip_version = "IPV4"
    }
    "staging-subnet-v6" = {
      address    = var.global_ip_addresses.staging_subnet_v6
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