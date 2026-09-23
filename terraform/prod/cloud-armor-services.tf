resource "google_compute_security_policy" "services" {
  # Layer 7 DDoS defence, opted in per policy via enable_ddos.
  adaptive_protection_config {
    layer_7_ddos_defense_config {
      enable          = var.cloud_armor_policies.services.enable_ddos
      rule_visibility = "STANDARD"
    }
  }

  name    = var.cloud_armor_policies.services.name
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
        expression = var.cloud_armor_waf_expressions.services_additional
      }
    }

    preview  = var.cloud_armor_policies.services.preview
    priority = 1001
  }

  rule {
    action = "deny(403)"

    match {
      expr {
        expression = var.cloud_armor_waf_expressions.services
      }
    }

    preview  = var.cloud_armor_policies.services.preview
    priority = 1000
  }

  # Expression lives in Secret Manager. The pinned preview is deliberate.
  rule {
    action = "deny(403)"

    match {
      expr {
        expression = var.cloud_armor_waf_expressions.services_block
      }
    }

    preview  = false
    priority = 1100
  }

  type = "CLOUD_ARMOR"
}
