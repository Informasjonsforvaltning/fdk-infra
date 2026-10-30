
resource "google_compute_security_policy" "harvesters" {
  # Layer 7 DDoS defence, opted in per policy via enable_ddos.
  adaptive_protection_config {
    layer_7_ddos_defense_config {
      enable          = var.cloud_armor_policies.harvesters.enable_ddos
      rule_visibility = "STANDARD"
    }
  }

  name    = var.cloud_armor_policies.harvesters.name
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
        expression = var.cloud_armor_waf_expressions.harvesters
      }
    }

    preview  = var.cloud_armor_policies.harvesters.preview
    priority = 1000
  }

  rule {
    action      = "deny(404)"
    description = "Health and metrics endpoints are internal"

    match {
      expr {
        expression = local.cloud_armor_internal_paths
      }
    }

    priority = 1200
  }

  rule {
    action      = "allow"
    description = "Trusted sources, exempt from the request limits"

    match {
      config {
        src_ip_ranges = var.cloud_armor_trusted_ranges
      }

      versioned_expr = "SRC_IPS_V1"
    }

    priority = 1300
  }

  dynamic "rule" {
    for_each = local.cloud_armor_throttles.harvesters

    content {
      action      = "throttle"
      description = "Request limit for ${rule.key}"

      match {
        expr {
          expression = "request.headers['host'].lower().startsWith('${rule.key}')"
        }
      }

      priority = rule.value.priority

      rate_limit_options {
        conform_action = "allow"
        enforce_on_key = "IP"
        exceed_action  = "deny(429)"

        rate_limit_threshold {
          count        = rule.value.count
          interval_sec = rule.value.interval_sec
        }
      }
    }
  }

  type = "CLOUD_ARMOR"
}
