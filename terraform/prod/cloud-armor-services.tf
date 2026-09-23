resource "google_compute_security_policy" "services" {
  # Layer 7 DDoS defence, opted in per policy via enable_ddos.
  dynamic "adaptive_protection_config" {
    for_each = var.cloud_armor_policies.services.enable_ddos ? [1] : []
    content {
      layer_7_ddos_defense_config {
        enable          = true
        rule_visibility = "STANDARD"
      }
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

  # Expression lives in Secret Manager, as with the rules above. Unlike the
  # rules above, this one does not follow the policy-level preview toggle:
  # it stays enforcing even when the policy is put into preview for a dry run.
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
