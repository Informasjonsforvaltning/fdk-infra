
resource "google_compute_security_policy" "bff" {
  name    = var.cloud_armor_policies.bff.name
  project = var.project_id

  rule {
    action      = "allow"
    description = "Default rule, higher priority overrides it"

    match {
      config {
        src_ip_ranges = ["*"]
      }

      versioned_expr = "SRC_IPS_V1"
    }

    priority = 2147483647
  }

  rule {
    action = "deny(403)"

    match {
      expr {
        expression = var.cloud_armor_waf_expressions.bff
      }
    }

    preview  = var.cloud_armor_policies.bff.preview
    priority = 1000
  }

  type = "CLOUD_ARMOR"
}
