
resource "google_compute_security_policy" "registration" {
  name    = var.cloud_armor_policies.registration.name
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
        expression = var.cloud_armor_waf_expressions.registration
      }
    }

    preview  = var.cloud_armor_policies.registration.preview
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
    for_each = local.cloud_armor_throttles.registration

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
